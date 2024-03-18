//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import MediaPlayer
import PillarboxPlayer

struct MediaMetadataMapper: Mapper {
    let metadata: MediaMetadata

    func mediaItemInfo(at time: CMTime?, with error: (any Error)?) -> NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = metadata.subtitle
        nowPlayingInfo[MPMediaItemPropertyComments] = metadata.description
        if let image = metadata.image {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        return nowPlayingInfo
    }

    func metadataItems(at time: CMTime?, with error: (any Error)?) -> [AVMetadataItem] {
        []
    }

    func navigationMarkerGroups() -> [AVTimedMetadataGroup] {
        []
    }
}
