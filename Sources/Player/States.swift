//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Player {
    /// Player states.
    public enum State {
        /// The player is idle.
        case idle
        /// The player is currently playing content.
        case playing
        /// The player has been paused.
        case paused
        /// The player ended playback of an item.
        case ended
        /// The player encountered an error.
        case failed(error: Error)
    }

    enum ItemState {
        case unknown
        case readyToPlay
        case ended
        case failed(error: Error)
    }

    static nonisolated func areDuplicates(_ lhsState: Player.State, _ rhsState: Player.State) -> Bool {
        switch (lhsState, rhsState) {
        case (.idle, .idle),
            (.playing, .playing),
            (.paused, .paused),
            (.ended, .ended):
            return true
        default:
            return false
        }
    }
}
