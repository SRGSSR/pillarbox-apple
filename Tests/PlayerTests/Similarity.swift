//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia

extension Player.State: Similar {
    /// Similarity ignores associated values
    static func ~= (lhs: Player.State, rhs: Player.State) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.playing, .playing), (.paused, .paused),
            (.ended, .ended), (.failed, .failed):
            return true
        default:
            return false
        }
    }
}

extension Player.ItemState: Similar {
    /// Similarity ignores associated values
    static func ~= (lhs: Player.ItemState, rhs: Player.ItemState) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown), (.readyToPlay, .readyToPlay), (.ended, .ended),
            (.failed, .failed):
            return true
        default:
            return false
        }
    }
}

func close(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
    Time.close(within: tolerance)
}

func close(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
    Time.close(within: tolerance)
}
