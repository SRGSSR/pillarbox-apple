//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct AVPlayerContext {
    let currentItemContext: AVPlayerItemContext
    let rate: Float

    var playbackState: PlaybackState {
        .init(itemState: currentItemContext.state, rate: rate)
    }
}
