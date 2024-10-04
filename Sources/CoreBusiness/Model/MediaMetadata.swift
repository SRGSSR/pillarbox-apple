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

    /// The URL at which the playback context was retrieved.
    public let mediaCompositionUrl: URL?

    /// The main chapter.
    public let mainChapter: MediaComposition.Chapter

    /// The resource to be played.
    public let resource: MediaComposition.Resource

    private let dataProvider: DataProvider

    /// The stream type.
    public var streamType: StreamType {
        resource.streamType
    }

    /// The available chapters.
    public var chapters: [Chapter] {
        guard mainChapter.mediaType == .video else { return [] }
        return mediaComposition.chapters(relatedTo: mainChapter).map { chapter in
            .init(
                identifier: chapter.urn,
                title: chapter.title,
                imageSource: .url(imageUrl(for: chapter)),
                timeRange: chapter.timeRange
            )
        }
    }

    /// The consolidated comScore analytics data.
    var analyticsData: [String: String] {
        var analyticsData = mainChapter.analyticsData
        guard !analyticsData.isEmpty else { return [:] }
        analyticsData.merge(mediaComposition.analyticsData) { _, new in new }
        analyticsData.merge(resource.analyticsData) { _, new in new }
        return analyticsData
    }

    /// The consolidated Commanders Act analytics data.
    var analyticsMetadata: [String: String] {
        var analyticsMetadata = mainChapter.analyticsMetadata
        guard !analyticsMetadata.isEmpty else { return [:] }
        analyticsMetadata.merge(mediaComposition.analyticsMetadata) { _, new in new }
        analyticsMetadata.merge(resource.analyticsMetadata) { _, new in new }
        return analyticsMetadata
    }

    init(mediaCompositionResponse: MediaCompositionResponse, dataProvider: DataProvider) throws {
        let mediaComposition = mediaCompositionResponse.mediaComposition
        guard let mainChapter = mediaComposition.chapter(for: mediaComposition.chapterUrn) else {
            throw DataError.noResourceAvailable
        }
        if let blockingReason = mainChapter.blockingReason {
            throw DataError.blocked(withMessage: blockingReason.description)
        }
        guard let resource = mainChapter.recommendedResource else {
            throw DataError.noResourceAvailable
        }
        self.mediaComposition = mediaComposition
        self.mediaCompositionUrl = mediaCompositionResponse.response.url
        self.mainChapter = mainChapter
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
            imageSource: .url(imageUrl(for: mainChapter)),
            viewport: viewport,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges
        )
    }

    var title: String {
        guard mainChapter.contentType != .livestream else { return mainChapter.title }
        if let show = mediaComposition.show {
            return show.title
        }
        else {
            return mainChapter.title
        }
    }

    var subtitle: String? {
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
        mainChapter.description
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

    var viewport: Viewport {
        switch resource.presentation {
        case .default:
            return .standard
        case .video360:
            return .monoscopic
        }
    }

    private var timeRanges: [TimeRange] {
        blockedTimeRanges + creditsTimeRanges
    }

    private var blockedTimeRanges: [TimeRange] {
        mainChapter.segments
            .filter { $0.blockingReason != nil }
            .map { segment in
                TimeRange(kind: .blocked, start: segment.timeRange.start, end: segment.timeRange.end)
            }
    }

    private var creditsTimeRanges: [TimeRange] {
        mainChapter.timeIntervals.map { interval in
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
