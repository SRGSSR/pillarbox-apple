//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Circumspect
import Foundation
import Player

func ~= (lhs: Error, rhs: Error) -> Bool {
    let lhsError = lhs as NSError
    let rhsError = rhs as NSError
    return lhsError.domain == rhsError.domain && lhsError.code == rhsError.code
        && lhsError.localizedDescription == rhsError.localizedDescription
}

extension PlaybackState: Similar {
    public static func ~= (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.playing, .playing), (.paused, .paused), (.ended, .ended):
            return true
        case let (.failed(error: lhsError), .failed(error: rhsError)):
            return lhsError ~= rhsError
        default:
            return false
        }
    }
}
