//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxPlayer
import UIKit

public struct MediaMetadata {
    private static let dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Europe/Zurich")
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()

    let mainChapter: MediaComposition.Chapter
    let mediaComposition: MediaComposition
    let mediaCompositionUrl: URL?
    let resource: MediaComposition.Resource?

    private let dataProvider: DataProvider

    var analyticsData: [String: String] {
        var analyticsData = mainChapter.analyticsData
        guard !analyticsData.isEmpty else { return [:] }
        analyticsData.merge(mediaComposition.analyticsData) { _, new in new }
        if let resource {
            analyticsData.merge(resource.analyticsData) { _, new in new }
        }
        return analyticsData
    }

    var analyticsMetadata: [String: String] {
        var analyticsMetadata = mainChapter.analyticsMetadata
        guard !analyticsMetadata.isEmpty else { return [:] }
        analyticsMetadata.merge(mediaComposition.analyticsMetadata) { _, new in new }
        if let resource {
            analyticsMetadata.merge(resource.analyticsMetadata) { _, new in new }
        }
        return analyticsMetadata
    }

    var blockingReason: BlockingReason? {
        mainChapter.blockingReason
    }

    var streamType: StreamType {
        resource?.streamType ?? .unknown
    }

    init(mediaCompositionResponse: MediaCompositionResponse, dataProvider: DataProvider) throws {
        let mediaComposition = mediaCompositionResponse.mediaComposition
        guard let mainChapter = mediaComposition.chapter(for: mediaComposition.chapterUrn) else {
            throw SourceError()
        }
        self.mediaComposition = mediaComposition
        self.mediaCompositionUrl = mediaCompositionResponse.response.url
        self.mainChapter = mainChapter
        self.resource = mainChapter.recommendedResource
        self.dataProvider = dataProvider
    }

    private static func areRedundant(chapter: MediaComposition.Chapter, show: MediaComposition.Show) -> Bool {
        chapter.title.lowercased() == show.title.lowercased()
    }

    func playerMetadata() -> PlayerMetadata {
        .init(
            identifier: mediaComposition.chapterUrn,
            title: title,
            subtitle: subtitle,
            description: description,
            imageSource: .url(
                standardResolution: standardResolutionImageUrl(for: mainChapter),
                lowResolution: lowResolutionImageUrl(for: mainChapter)
            ),
            viewport: viewport,
            episodeInformation: episodeInformation,
            chapters: chapters,
            timeRanges: timeRanges
        )
    }
}

extension MediaMetadata {
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

    var viewport: Viewport {
        switch resource?.presentation {
        case .video360:
            return .monoscopic
        default:
            return .standard
        }
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

    var chapters: [Chapter] {
        mediaComposition.chapters(relatedTo: mainChapter).map { chapter in
            .init(
                identifier: chapter.urn,
                title: chapter.title,
                imageSource: .url(
                    standardResolution: standardResolutionImageUrl(for: chapter),
                    lowResolution: lowResolutionImageUrl(for: chapter)
                ),
                timeRange: chapter.timeRange
            )
        }
    }

    var timeRanges: [TimeRange] {
        blockedTimeRanges + creditsTimeRanges
    }

    var blockedTimeRanges: [TimeRange] {
        mainChapter.segments
            .filter { $0.blockingReason != nil }
            .map { segment in
                TimeRange(kind: .blocked, start: segment.timeRange.start, end: segment.timeRange.end)
            }
    }

    var creditsTimeRanges: [TimeRange] {
        mainChapter.timeIntervals.map { interval in
            switch interval.kind {
            case .openingCredits:
                TimeRange(kind: .credits(.opening), start: interval.timeRange.start, end: interval.timeRange.end)
            case .closingCredits:
                TimeRange(kind: .credits(.closing), start: interval.timeRange.start, end: interval.timeRange.end)
            }
        }
    }

    func standardResolutionImageUrl(for chapter: MediaComposition.Chapter) -> URL {
        dataProvider.resizedImageUrl(chapter.imageUrl, width: .width720)
    }

    func lowResolutionImageUrl(for chapter: MediaComposition.Chapter) -> URL {
        dataProvider.resizedImageUrl(chapter.imageUrl, width: .width320)
    }
}
