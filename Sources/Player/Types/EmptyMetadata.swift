//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

final class EmptyMetadata<M>: PlayerMetadata {
    init(configuration: Void) {}

    func update(metadata: M) {}

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
