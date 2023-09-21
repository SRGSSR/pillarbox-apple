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

    static var empty: Self {
        .init(currentItemContext: .empty, rate: 0, isSeeking: false, isExternalPlaybackActive: false, isMuted: false)
    }

    var playbackState: PlaybackState {
        .init(itemState: currentItemContext.state, rate: rate)
    }
}
