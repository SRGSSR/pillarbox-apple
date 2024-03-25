//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaPlayer
import UIKit

public final class CommonMetadata: PlayerMetadata {
    public struct Metadata {
        public let title: String?
        public let subtitle: String?
        public let description: String?

        // TODO: Likely better as a URL => would need to have lifecycle methods on PlayerMetadata so that we can
        //       retrieve the image only when needed.
        public let image: UIImage?

        public init(title: String? = nil, subtitle: String? = nil, description: String? = nil, image: UIImage? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.description = description
            self.image = image
        }
    }

    private var metadata: Metadata?

    public init(configuration: Void) {}

    public func update(metadata: Metadata) {
        self.metadata = metadata
    }

    public func mediaItemInfo() -> NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
        if let metadata {
            nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
            nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.subtitle
            nowPlayingInfo[MPMediaItemPropertyComments] = metadata.description
            if let image = metadata.image {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            }
        }
        return nowPlayingInfo
    }

    public func metadataItems() -> [AVMetadataItem] {
        guard let metadata else { return [] }
        return [
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
