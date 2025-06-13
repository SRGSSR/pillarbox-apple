//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Nimble

infix operator ~~ : ComparisonPrecedence

/// A protocol to define similarity for types.
///
/// You can implement similarity for types not conforming to `Equatable` but which still need to be meaningfully
/// compared in tests.
public protocol Similar {
    /// Returns whether the two sides can be considered to be similar.
    static func ~~ (lhs: Self, rhs: Self) -> Bool
}

/// Matches against an expected similar value, displaying mismatches in a user-readable form.
public func equalDiff<T>(_ expectedValue: T?) -> Matcher<T> where T: Similar {
    equalDiff(expectedValue, by: ~~)
}

/// Matches against an expected similar value.
public func beSimilarTo<T>(_ expectedValue: T?) -> Matcher<T> where T: Similar {
    equal(expectedValue, by: ~~)
}

extension Array: Similar where Element: Similar {
    // swiftlint:disable:next missing_docs
    public static func ~~ (lhs: Self, rhs: Self) -> Bool {
        guard lhs.count == rhs.count else { return false }
        return zip(lhs, rhs).allSatisfy(~~)
    }
}

extension Optional: Similar where Wrapped: Similar {
    // swiftlint:disable:next missing_docs
    public static func ~~ (lhs: Wrapped?, rhs: Wrapped?) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.none, .some), (.some, .none):
            return false
        case let (.some(lhs), .some(rhs)):
            return lhs ~~ rhs
        }
    }
}
