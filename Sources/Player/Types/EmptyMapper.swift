//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class EmptyMapper: Mapper {
    init() {}

    func update(metadata: Never) {}

    func mediaItemInfo(with error: Error?) -> NowPlayingInfo {
        .init()
    }
    
    func metadataItems() -> [AVMetadataItem] {
        []
    }
    
    func navigationMarkerGroups() -> [AVTimedMetadataGroup] {
        []
    }
}
