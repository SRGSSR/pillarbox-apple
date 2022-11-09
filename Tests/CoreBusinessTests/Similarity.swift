//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Circumspect
import Foundation
import Player

extension PlaybackState: Similar {
    private static func areSimilar(_ lhsError: Error, _ rhsError: Error) -> Bool {
        let nsLhsError = lhsError as NSError
        let nsRhsError = rhsError as NSError
        return nsLhsError.domain == nsRhsError.domain && nsLhsError.code == nsRhsError.code
            && nsLhsError.localizedDescription == nsRhsError.localizedDescription
    }

    public static func ~= (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.playing, .playing), (.paused, .paused), (.ended, .ended):
            return true
        case let (.failed(error: lhsError), .failed(error: rhsError)):
            return areSimilar(lhsError, rhsError)
        default:
            return false
        }
    }
}
