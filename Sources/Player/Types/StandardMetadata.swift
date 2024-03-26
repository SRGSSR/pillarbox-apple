//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaPlayer
import UIKit

/// A struct that conforms to the `PlayerItemMetadata`.
public struct StandardMetadata: PlayerItemMetadata {
    public init(configuration: Void) {}

    public func nowPlayingInfo(from metadata: Metadata) -> NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
        // FIXME: Probably twisting metadata here
        nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.subtitle
        nowPlayingInfo[MPMediaItemPropertyComments] = metadata.description
        if let image = metadata.image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        return nowPlayingInfo
    }

    public func items(from metadata: Metadata) -> [AVMetadataItem] {
        [
            .init(for: .commonIdentifierAssetIdentifier, value: metadata.identifier),
            .init(for: .commonIdentifierTitle, value: metadata.title),
            .init(for: .iTunesMetadataTrackSubTitle, value: metadata.subtitle),
            .init(for: .commonIdentifierArtwork, value: metadata.image?.pngData()),
            .init(for: .commonIdentifierDescription, value: metadata.description)
        ]
        .compactMap { $0 }
    }

    public func timedGroups(from metadata: Metadata) -> [AVTimedMetadataGroup] {
        []
    }

    public func chapterGroups(from metadata: Metadata) -> [AVTimedMetadataGroup] {
        metadata.chapters.map { chapter in
            AVTimedMetadataGroup(
                items: [
                    .init(for: .commonIdentifierAssetIdentifier, value: metadata.identifier),
                    .init(for: .commonIdentifierTitle, value: chapter.title),
                    .init(for: .commonIdentifierArtwork, value: chapter.artwork?.pngData())
                ].compactMap { $0 },
                timeRange: chapter.timeRange
            )
        }
    }
}

// swiftlint:disable missing_docs
public extension StandardMetadata {
    struct Metadata {
        public let identifier: String?
        public let title: String?
        public let subtitle: String?
        public let description: String?
        public let image: UIImage?
        public let chapters: [Chapter]

        public init(
            identifier: String? = nil,
            title: String? = nil,
            subtitle: String? = nil,
            description: String? = nil,
            image: UIImage? = nil,
            chapters: [Chapter] = []
        ) {
            self.identifier = identifier
            self.title = title
            self.subtitle = subtitle
            self.description = description
            self.image = image
            self.chapters = chapters
        }
    }
}

public extension StandardMetadata {
    struct Chapter {
        let title: String
        let timeRange: CMTimeRange
        var artwork: UIImage?

        public init(title: String, range: CMTimeRange, image: UIImage?) {
            self.title = title
            self.timeRange = range
            self.artwork = image
        }
    }
}
// swiftlint:enable missing_docs
