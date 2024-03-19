//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia
import MediaPlayer
import PillarboxPlayer

final class MediaMapper: MetadataMapper {
    private var metadata: Media?

    init() {}

    private static func metadataItem<T>(for identifier: AVMetadataIdentifier, value: T?) -> AVMetadataItem? {
        guard let value else { return nil }
        let item = AVMutableMetadataItem()
        item.identifier = identifier
        item.value = value as? NSCopying & NSObjectProtocol
        item.extendedLanguageTag = "und"
        return item.copy() as? AVMetadataItem
    }

    func update(metadata: Media) {
        self.metadata = metadata
    }

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo {
        guard let metadata else { return .init() }
        var nowPlayingInfo = NowPlayingInfo()
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
        nowPlayingInfo[MPMediaItemPropertyComments] = metadata.description
        if let image = metadata.image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        return nowPlayingInfo
    }

    func metadataItems() -> [AVMetadataItem] {
        guard let metadata else { return [] }
        return [
            Self.metadataItem(for: .commonIdentifierTitle, value: metadata.title),
            Self.metadataItem(for: .commonIdentifierArtwork, value: metadata.image?.pngData()),
            Self.metadataItem(for: .commonIdentifierDescription, value: metadata.description)
        ]
        .compactMap { $0 }
    }

    func navigationMarkerGroups() -> [AVTimedMetadataGroup] {
        []
    }
}
