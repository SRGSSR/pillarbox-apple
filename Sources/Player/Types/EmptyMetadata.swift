//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct EmptyMetadata<M>: PlayerMetadata {
    init(configuration: Void) {}

    func mediaItemInfo(from metadata: M) -> NowPlayingInfo {
        .init()
    }

    func metadataItems(from metadata: M) -> [AVMetadataItem] {
        []
    }
}
