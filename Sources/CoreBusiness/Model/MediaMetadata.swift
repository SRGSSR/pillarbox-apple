//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
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
    public let resource: Resource

    /// A catalog of images associated with the context.
    let imageCatalog: ImageCatalog

    /// The title recommended for display.
    public var title: String {
        let mainChapter = mediaComposition.mainChapter
        guard mainChapter.contentType != .livestream else { return mainChapter.title }
        if let show = mediaComposition.show {
            return show.title
        }
        else {
            return mainChapter.title
        }
    }

    /// A recommended identifier for the content.
    public var identifier: String {
        mediaComposition.chapterUrn
    }

    /// The subtitle recommended for display.
    public var subtitle: String? {
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

    /// The content description.
    public var description: String? {
        mediaComposition.mainChapter.description
    }

    /// The stream type.
    public var streamType: StreamType {
        resource.streamType
    }

    /// A description of the episode (season / episode).
    public var episodeDescription: String? {
        guard let episode = mediaComposition.episode, let episodeNumber = episode.number else { return nil }
        if let seasonNumber = episode.seasonNumber {
            return String(localized: "S\(seasonNumber), E\(episodeNumber)", bundle: .module, comment: "Short season / episode information")
        }
        else {
            return String(localized: "E\(episodeNumber)", bundle: .module, comment: "Short episode information")
        }
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

    init(mediaComposition: MediaComposition, resource: Resource, imageCatalog: ImageCatalog) {
        self.mediaComposition = mediaComposition
        self.resource = resource
        self.imageCatalog = imageCatalog
    }

    private static func areRedundant(chapter: Chapter, show: Show) -> Bool {
        chapter.title.lowercased() == show.title.lowercased()
    }

    /// The image associated with a chapter, if any.
    public func image(for chapter: Chapter) -> UIImage? {
        imageCatalog.image(for: chapter.urn)
    }

    func placeholderImage() -> UIImage {
        imageCatalog.placeholderImage()
    }
}

extension MediaMetadata: PlayerItemMetadata {
    public func items() -> [AVMetadataItem] {
        let image = image(for: mediaComposition.mainChapter) ?? placeholderImage()
        return [
            .init(for: .commonIdentifierAssetIdentifier, value: identifier),
            .init(for: .commonIdentifierTitle, value: title),
            .init(for: .iTunesMetadataTrackSubTitle, value: subtitle),
            .init(for: .commonIdentifierArtwork, value: image.pngData()),
            .init(for: .commonIdentifierDescription, value: description),
            .init(for: .quickTimeUserDataCreationDate, value: episodeDescription)
        ].compactMap { $0 }
    }

    public func timedGroups() -> [AVTimedMetadataGroup] {
        []
    }

    public func chapterGroups() -> [AVTimedMetadataGroup] {
        mediaComposition.chapters.map { chapter in
            let image = image(for: chapter) ?? placeholderImage()
            return AVTimedMetadataGroup(
                items: [
                    .init(for: .commonIdentifierAssetIdentifier, value: chapter.identifier),
                    .init(for: .commonIdentifierTitle, value: chapter.title),
                    .init(for: .commonIdentifierArtwork, value: image.pngData())
                ].compactMap { $0 },
                timeRange: chapter.timeRange
            )
        }
    }
}
