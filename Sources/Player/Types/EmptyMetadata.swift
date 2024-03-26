//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct EmptyMetadata<M>: PlayerItemMetadata {
    init(configuration: Void) {}

    func nowPlayingInfo(from metadata: M) -> NowPlayingInfo {
        .init()
    }

    func metadataItems(from metadata: M) -> [AVMetadataItem] {
        []
    }
}
