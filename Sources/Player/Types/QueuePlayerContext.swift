//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public struct QueuePlayerContext: Equatable {
    static var empty: Self {
        .init(currentItemContext: .empty, rate: 0, isSeeking: false, isExternalPlaybackActive: false, isMuted: false)
    }

    let currentItemContext: AVPlayerItemContext
    let rate: Float
    let isSeeking: Bool
    let isExternalPlaybackActive: Bool
    let isMuted: Bool

    public var playbackState: PlaybackState {
        .init(itemState: currentItemContext.state, rate: rate)
    }
}
