//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

extension Player {
    public enum State: Equatable {
        case idle
        case playing
        case paused
        case ended
        case failed(error: Error)

        public static func == (lhs: Player.State, rhs: Player.State) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.playing, .playing), (.paused, .paused),
                (.ended, .ended), (.failed, .failed):
                return true
            default:
                return false
            }
        }
    }
}
