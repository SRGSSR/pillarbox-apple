//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Defines similarity for types not conforming to `Equatable` and which need to be meaningfully compared in tests.
public protocol Similar {
    /// Must return `true` iff the two sides can be considered to be similar.
    static func ~= (lhs: Self, rhs: Self) -> Bool
}

extension Optional: Similar where Wrapped: Similar {
    public static func ~= (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.none, .some(_)), (.some(_), .none):
            return false
        case let (.some(lhs), .some(rhs)):
            return lhs ~= rhs
        }
    }
}
