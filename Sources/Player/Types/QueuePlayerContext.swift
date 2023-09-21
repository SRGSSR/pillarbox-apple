//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct QueuePlayerContext {
    let currentItemContext: AVPlayerItemContext
    let rate: Float
    let isSeeking: Bool
    let isExternalPlaybackActive: Bool
    let isMuted: Bool

    var playbackState: PlaybackState {
        .init(itemState: currentItemContext.state, rate: rate)
    }
}
