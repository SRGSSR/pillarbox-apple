//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia
import MediaPlayer
import PillarboxPlayer

struct MediaMapper: Mapper {
    let metadata: Media

    func mediaItemInfo(at time: CMTime?, with error: (any Error)?) -> NowPlayingInfo {
        var nowPlayingInfo = NowPlayingInfo()
        nowPlayingInfo[MPMediaItemPropertyTitle] = metadata.title
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
