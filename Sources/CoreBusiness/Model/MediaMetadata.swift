//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import PillarboxPlayer

/// Metadata associated with content loaded from a URN.
public struct MediaMetadata {
    /// The playback context.
    public let mediaComposition: MediaComposition

    /// The URL at which the playback context was retrieved.
    public let mediaCompositionUrl: URL?

    /// Useful response headers received when fetching the media composition.
    public let mediaCompositionHeaders: [String: String]

    /// The main chapter.
    public let mainChapter: MediaComposition.Chapter

    /// The resource to be played.
    public let resource: MediaComposition.Resource?

    private let dataProvider: DataProvider

    /// The stream type.
    public var streamType: StreamType {
        resource?.streamType ?? .unknown
    }

    /// The available chapters.
    public var chapters: [Chapter] {
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

    /// The consolidated comScore analytics data.
    var analyticsData: [String: String] {
        var analyticsData = mainChapter.analyticsData
        guard !analyticsData.isEmpty else { return [:] }
        analyticsData.merge(mediaComposition.analyticsData) { _, new in new }
        if let resource {
            analyticsData.merge(resource.analyticsData) { _, new in new }
        }
        return analyticsData
    }

    /// The consolidated Commanders Act analytics data.
    var analyticsMetadata: [String: String] {
        var analyticsMetadata = mainChapter.analyticsMetadata
        guard !analyticsMetadata.isEmpty else { return [:] }
        analyticsMetadata.merge(mediaComposition.analyticsMetadata) { _, new in new }
        if let resource {
            analyticsMetadata.merge(resource.analyticsMetadata) { _, new in new }
        }
        return analyticsMetadata
    }

    init(mediaCompositionResponse: MediaCompositionResponse, dataProvider: DataProvider) throws {
        let mediaComposition = mediaCompositionResponse.mediaComposition
        guard let mainChapter = mediaComposition.chapter(for: mediaComposition.chapterUrn) else {
            throw SourceError()
        }
        self.mediaComposition = mediaComposition
        self.mediaCompositionUrl = mediaCompositionResponse.response.url
        self.mediaCompositionHeaders = Self.mediaCompositionHeaders(from: mediaCompositionResponse.response)
        self.mainChapter = mainChapter
        self.resource = mainChapter.recommendedResource
        self.dataProvider = dataProvider
    }

    private static func areRedundant(chapter: MediaComposition.Chapter, show: MediaComposition.Show) -> Bool {
        chapter.title.lowercased() == show.title.lowercased()
    }

    private static func mediaCompositionHeaders(from response: URLResponse) -> [String: String] {
        guard let httpResponse = response as? HTTPURLResponse, let headers = httpResponse.allHeaderFields as? [String: String] else { return [:] }
        return headers.filter { key, _ in
            ["Akamai-GRN", "x-location-info", "x-proxy-detection-info", "X-tracing-id"].contains(key)
        }
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

    var description: String? {
        mainChapter.description
    }

    var episodeInformation: EpisodeInformation? {
        guard let episode = mediaComposition.episode, let episodeNumber = episode.number else { return nil }
        if let seasonNumber = episode.seasonNumber {
            return .init(episode: episodeNumber, season: seasonNumber)
        }
        else {
            return .init(episode: episodeNumber)
        }
    }

    var viewport: Viewport {
        switch resource?.presentation {
        case .video360:
            return .monoscopic
        default:
            return .standard
        }
    }

    var blockingReason: MediaComposition.BlockingReason? {
        mainChapter.blockingReason
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

    func playerMetadata(dateFormat: DateFormat) -> PlayerMetadata {
        .init(
            identifier: mediaComposition.chapterUrn,
            title: title,
            subtitle: subtitle(dateFormat: dateFormat),
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

    func subtitle(dateFormat: DateFormat) -> String? {
        guard mainChapter.contentType != .livestream else { return nil }
        if let show = mediaComposition.show {
            if Self.areRedundant(chapter: mainChapter, show: show) {
                return DateFormatter(format: dateFormat).string(from: mainChapter.date)
            }
            else {
                return mainChapter.title
            }
        }
        else {
            return nil
        }
    }

    private func standardResolutionImageUrl(for chapter: MediaComposition.Chapter) -> URL {
        dataProvider.resizedImageUrl(chapter.imageUrl, width: .width720)
    }

    private func lowResolutionImageUrl(for chapter: MediaComposition.Chapter) -> URL {
        dataProvider.resizedImageUrl(chapter.imageUrl, width: .width320)
    }
}
