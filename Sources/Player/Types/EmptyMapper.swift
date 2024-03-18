//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct EmptyMapper: Mapper {
    init(metadata: Never) {}

    func mediaItemInfo(at time: CMTime?, with error: (any Error)?) -> NowPlayingInfo {
        .init()
    }
    
    func metadataItems(at time: CMTime?, with error: (any Error)?) -> [AVMetadataItem] {
        []
    }
    
    func navigationMarkerGroups() -> [AVTimedMetadataGroup] {
        []
    }
}
