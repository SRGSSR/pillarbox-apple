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

    /// The resource to be played.
    public let resource: MediaComposition.Resource

    /// A catalog of images associated with the context.
    private let imageCatalog: ImageCatalog

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

    init(mediaComposition: MediaComposition, resource: MediaComposition.Resource, imageCatalog: ImageCatalog) {
        self.mediaComposition = mediaComposition
        self.resource = resource
        self.imageCatalog = imageCatalog
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
            image: artworkImage(for: mediaComposition.mainChapter),
            episodeInformation: episodeInformation,
            chapters: chapters
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

    private var chapters: [ChapterMetadata] {
        mediaComposition.chapters.map { chapter in
            .init(
                identifier: chapter.urn,
                title: chapter.title,
                image: artworkImage(for: chapter),
                timeRange: chapter.timeRange
            )
        }
    }

    private func image(for chapter: MediaComposition.Chapter) -> UIImage? {
        imageCatalog.image(for: chapter.urn)
    }

    private func artworkImage(for chapter: MediaComposition.Chapter) -> UIImage? {
#if os(tvOS)
        image(for: chapter) ?? imageCatalog.placeholderImage()
#else
        image(for: chapter)
#endif
    }
}
