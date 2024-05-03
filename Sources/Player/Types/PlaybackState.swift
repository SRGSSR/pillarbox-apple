//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

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

    init(itemStatus: ItemStatus, rate: Float) {
        switch itemStatus {
        case .readyToPlay:
            self = (rate == 0) ? .paused : .playing
        case .ended:
            self = .ended
        case .unknown:
            self = .idle
        }
    }
}
