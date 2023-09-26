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

    public let currentItemContext: AVPlayerItemContext
    public let rate: Float
    public let isSeeking: Bool
    public let isExternalPlaybackActive: Bool
    public let isMuted: Bool

    public var playbackState: PlaybackState {
        .init(itemState: currentItemContext.state, rate: rate)
    }
}
