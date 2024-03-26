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
            metadataItem(for: .commonIdentifierTitle, value: metadata.title),
            metadataItem(for: .iTunesMetadataTrackSubTitle, value: metadata.subtitle),
            metadataItem(for: .commonIdentifierArtwork, value: metadata.image?.pngData()),
            metadataItem(for: .commonIdentifierDescription, value: metadata.description)
        ]
        .compactMap { $0 }
    }

    private func metadataItem<T>(for identifier: AVMetadataIdentifier, value: T?) -> AVMetadataItem? {
        guard let value else { return nil }
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item.copy() as? AVMetadataItem
    }
}
