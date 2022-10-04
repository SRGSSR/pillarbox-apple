//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Circumspect
import Player

extension PlaybackState: Similar {
    public static func ~= (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.playing, .playing), (.paused, .paused), (.ended, .ended), (.failed, .failed):
            return true
        default:
            return false
        }
    }
}
