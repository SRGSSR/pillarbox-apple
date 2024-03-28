//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaPlayer
import UIKit

public struct StandardMetadata: PlayerItemMetadata {
    public struct Metadata {
        public let title: String?
        public let subtitle: String?
        public let description: String?
        public let image: UIImage?

        public init(title: String? = nil, subtitle: String? = nil, description: String? = nil, image: UIImage? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.description = description
            self.image = image
        }
    }

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

    public func metadataItems(from metadata: Metadata) -> [AVMetadataItem] {
        [
            .init(for: .commonIdentifierTitle, value: metadata.title),
            .init(for: .iTunesMetadataTrackSubTitle, value: metadata.subtitle),
            .init(for: .commonIdentifierArtwork, value: metadata.image?.pngData()),
            .init(for: .commonIdentifierDescription, value: metadata.description)
        ]
        .compactMap { $0 }
    }
}
