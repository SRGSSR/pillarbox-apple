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
        nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.subtitle
        nowPlayingInfo[MPMediaItemPropertyComments] = metadata.description
        if let image = metadata.image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        return nowPlayingInfo
    }

    public func items(from metadata: Metadata) -> [AVMetadataItem] {
        [
            .init(for: .commonIdentifierTitle, value: metadata.title),
            .init(for: .iTunesMetadataTrackSubTitle, value: metadata.subtitle),
            .init(for: .commonIdentifierArtwork, value: metadata.image?.pngData()),
            .init(for: .commonIdentifierDescription, value: metadata.description)
        ]
        .compactMap { $0 }
    }

    public func chapterGroups(from metadata: Metadata) -> [AVTimedMetadataGroup] {
        metadata.chapters.map { chapter in
            AVTimedMetadataGroup(
                items: [
                    .init(for: .commonIdentifierTitle, value: chapter.title),
                    .init(for: .commonIdentifierArtwork, value: chapter.artwork)
                ].compactMap { $0 },
                timeRange: chapter.timeRange
            )
        }
    }
}

// swiftlint:disable missing_docs
public extension StandardMetadata {
    struct Metadata {
        public let title: String?
        public let subtitle: String?
        public let description: String?
        public let image: UIImage?
        public let chapters: [Chapter]

        public init(title: String? = nil, subtitle: String? = nil, description: String? = nil, image: UIImage? = nil, chapters: [Chapter] = []) {
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
        var artwork: Data?

        public init(title: String, range: CMTimeRange, imageUrl: URL) {
            self.title = title
            self.timeRange = range
            if let data = try? Data(contentsOf: imageUrl) {
                self.artwork = UIImage(data: data)?.pngData()
            }
        }
    }
}
// swiftlint:enable missing_docs
