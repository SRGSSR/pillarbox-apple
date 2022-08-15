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
            case (.idle, .idle), (.playing, .playing), (.paused, .paused), (.ended, .ended):
                return true
            case let (.failed(error: lhsError), .failed(error: rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            default:
                return false
            }
        }
    }
}
