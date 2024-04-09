//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaPlayer

public struct PlayerMetadata {
    struct Data {
        static let empty = Self(items: [], timedGroups: [], chapterGroups: [])

        let items: [MetadataItem]
        let timedGroups: [TimedMetadataGroup]
        let chapterGroups: [TimedMetadataGroup]
    }

    static let empty = Self(content: .empty, resource: .empty)

    let content: Data
    let resource: Data

    public var items: [MetadataItem] {
        !content.items.isEmpty ? content.items : resource.items
    }

    public var timedGroups: [TimedMetadataGroup] {
        !content.timedGroups.isEmpty ? content.timedGroups : resource.timedGroups
    }

    public var chapterGroups: [TimedMetadataGroup] {
        !content.chapterGroups.isEmpty ? content.chapterGroups : resource.chapterGroups
    }

    // FIXME: Probably twisting metadata here. Have honest mapping between related AV / MP keys. Map as much as possible.
    var nowPlayingInfo: NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
        nowPlayingInfo[MPMediaItemPropertyTitle] = Self.metadataItem(with: .commonIdentifierTitle, in: items)?.stringValue
        nowPlayingInfo[MPMediaItemPropertyArtist] = Self.metadataItem(with: .iTunesMetadataTrackSubTitle, in: items)?.stringValue
        nowPlayingInfo[MPMediaItemPropertyComments] = Self.metadataItem(with: .commonIdentifierDescription, in: items)?.stringValue

        if let imageData = Self.metadataItem(with: .commonIdentifierArtwork, in: items)?.dataValue, let image = UIImage(data: imageData) {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        return nowPlayingInfo
    }

    // TODO: Provide such an API (with better type-safety) for easy public access to metadata?
    private static func metadataItem(with identifier: AVMetadataIdentifier, in items: [MetadataItem]) -> MetadataItem? {
        items.first { $0.identifier == identifier }
    }
}
