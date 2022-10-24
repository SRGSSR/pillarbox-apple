//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Nimble

/// Defines similarity for types not conforming to `Equatable` and which need to be meaningfully compared in tests.
public protocol Similar {
    /// Must return `true` iff the two sides can be considered to be similar.
    static func ~= (lhs: Self, rhs: Self) -> Bool
}

/// Nimble matcher displaying similarity differences in a friendly way.
public func equalDiff<T: Similar>(_ expectedValue: T?) -> Predicate<T> {
    equalDiff(expectedValue, by: ~=)
}

/// Nimble matcher displaying mismatches as differences.
public func equal<T: Similar>(_ expectedValue: T?) -> Predicate<T> {
    equal(expectedValue, by: ~=)
}

extension Array: Similar where Element: Similar {
    public static func ~= (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs, rhs).allSatisfy(~=)
    }
}

extension Optional: Similar where Wrapped: Similar {
    public static func ~= (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.none, .some), (.some, .none):
            return false
        case let (.some(lhs), .some(rhs)):
            return lhs ~= rhs
        }
    }
}
