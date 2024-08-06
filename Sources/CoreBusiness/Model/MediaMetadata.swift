//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

/// Metadata associated with content loaded from a URN.
public struct MediaMetadata {
    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    /// The playback context.
    public let mediaComposition: MediaComposition

    
    public let mediaCompositionUrl: URL?

    /// The resource to be played.
    public let resource: MediaComposition.Resource

    private let dataProvider: DataProvider

    /// The stream type.
    public var streamType: StreamType {
        resource.streamType
    }

    /// The consolidated comScore analytics data.
    var analyticsData: [String: String] {
        var analyticsData = mediaComposition.mainChapter.analyticsData
        guard !analyticsData.isEmpty else { return [:] }
        analyticsData.merge(mediaComposition.analyticsData) { _, new in new }
        analyticsData.merge(resource.analyticsData) { _, new in new }
        return analyticsData
    }

    /// The consolidated Commanders Act analytics data.
    var analyticsMetadata: [String: String] {
        var analyticsMetadata = mediaComposition.mainChapter.analyticsMetadata
        guard !analyticsMetadata.isEmpty else { return [:] }
        analyticsMetadata.merge(mediaComposition.analyticsMetadata) { _, new in new }
        analyticsMetadata.merge(resource.analyticsMetadata) { _, new in new }
        return analyticsMetadata
    }

    init(
        mediaCompositionResponse: MediaCompositionResponse,
        dataProvider: DataProvider
    ) throws {
        let mediaComposition = mediaCompositionResponse.mediaComposition
        guard let resource = mediaComposition.mainChapter.recommendedResource else {
            throw DataError.noResourceAvailable
        }
        self.mediaComposition = mediaComposition
        self.mediaCompositionUrl = mediaCompositionResponse.response.url
        self.resource = resource
        self.dataProvider = dataProvider
    }

    private static func areRedundant(chapter: MediaComposition.Chapter, show: MediaComposition.Show) -> Bool {
        chapter.title.lowercased() == show.title.lowercased()
    }
}

extension MediaMetadata: AssetMetadata {
    public var playerMetadata: PlayerMetadata {
        .init(
            identifier: mediaComposition.chapterUrn,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: .url(imageUrl(for: mediaComposition.mainChapter)),
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges
        )
    }

    var title: String {
        let mainChapter = mediaComposition.mainChapter
        guard mainChapter.contentType != .livestream else { return mainChapter.title }
        if let show = mediaComposition.show {
            return show.title
        }
        else {
            return mainChapter.title
        }
    }

    var subtitle: String? {
        let mainChapter = mediaComposition.mainChapter
        guard mainChapter.contentType != .livestream else { return nil }
        if let show = mediaComposition.show {
            if Self.areRedundant(chapter: mainChapter, show: show) {
                return Self.dateFormatter.string(from: mainChapter.date)
            }
            else {
                return mainChapter.title
            }
        }
        else {
            return nil
        }
    }

    var description: String? {
        mediaComposition.mainChapter.description
    }

    var episodeInformation: EpisodeInformation? {
        guard let episode = mediaComposition.episode, let episodeNumber = episode.number else { return nil }
        if let seasonNumber = episode.seasonNumber {
            return .long(season: seasonNumber, episode: episodeNumber)
        }
        else {
            return .short(episode: episodeNumber)
        }
    }

    private var chapters: [Chapter] {
        mediaComposition.chapters.map { chapter in
            .init(
                identifier: chapter.urn,
                title: chapter.title,
                imageSource: .url(imageUrl(for: chapter)),
                timeRange: chapter.timeRange
            )
        }
    }

    private var timeRanges: [TimeRange] {
        blockedTimeRanges + creditsTimeRanges
    }

    private var blockedTimeRanges: [TimeRange] {
        mediaComposition.mainChapter.segments
            .filter { $0.blockingReason != nil }
            .map { segment in
                TimeRange(kind: .blocked, start: segment.timeRange.start, end: segment.timeRange.end)
            }
    }

    private var creditsTimeRanges: [TimeRange] {
        mediaComposition.mainChapter.timeIntervals.map { interval in
            switch interval.kind {
            case .openingCredits:
                TimeRange(kind: .credits(.opening), start: interval.timeRange.start, end: interval.timeRange.end)
            case .closingCredits:
                TimeRange(kind: .credits(.closing), start: interval.timeRange.start, end: interval.timeRange.end)
            }
        }
    }

    private func imageUrl(for chapter: MediaComposition.Chapter) -> URL {
        dataProvider.resizedImageUrl(chapter.imageUrl, width: .width720)
    }
}
