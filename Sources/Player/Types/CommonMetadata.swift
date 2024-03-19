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

    public func mediaItemInfo(with error: Error?) -> NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
        if let metadata {
            nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
            nowPlayingInfo[MPMediaItemPropertyArtist] = error?.localizedDescription ?? metadata.subtitle
            nowPlayingInfo[MPMediaItemPropertyComments] = metadata.description
            if let image = metadata.image {
                nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            }
        }
        else {
            // Fill the title so that the Control Center can be enabled for the asset, even if it has no associated
            // metadata.
            nowPlayingInfo[MPMediaItemPropertyTitle] = error?.localizedDescription ?? ""
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

    public func navigationMarkerGroups() -> [AVTimedMetadataGroup] {
        []
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
