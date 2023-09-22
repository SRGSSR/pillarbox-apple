//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A playback state.
public enum PlaybackState: Equatable {
    /// The player is idle.
    case idle
    /// The player is currently playing content.
    case playing
    /// The player has been paused.
    case paused
    /// The player ended playback of an item.
    case ended

    init(itemState: ItemState, rate: Float) {
        switch itemState {
        case .readyToPlay:
            self = (rate == 0) ? .paused : .playing
        case .ended:
            self = .ended
        case .unknown:
            self = .idle
        }
    }
}
