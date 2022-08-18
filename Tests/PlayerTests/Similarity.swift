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

/// Return a time comparator working having some tolerance
func close(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
    precondition(tolerance >= 0)
    return {
        CMTimeCompare(
            CMTimeAbsoluteValue(CMTimeSubtract($0, $1)),
            CMTimeMakeWithSeconds(tolerance, preferredTimescale: Int32(NSEC_PER_SEC))
        ) == -1
    }
}

/// Return a time range comparator working having some tolerance
func close(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
    precondition(tolerance >= 0)
    let timeClose: ((CMTime, CMTime) -> Bool) = close(within: tolerance)
    return {
        timeClose($0.start, $1.start) && timeClose($0.end, $1.end)
    }
}
