//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Difference
import Nimble

/// Matches against an expected value using some comparator.
public func equal<T>(_ expectedValue: T?, by areEquivalent: @escaping (T, T) -> Bool) -> Matcher<T> {
    // Directly borrowed from https://github.com/Quick/Nimble/blob/main/Sources/Nimble/Matchers/Equal.swift
    Matcher.define("equal <\(stringify(expectedValue))>") { actualExpression, message in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (.none, .some):
            return MatcherResult(status: .fail, message: message.appendedBeNilHint())
        case (_, .none):
            return MatcherResult(status: .fail, message: message)
        case let (.some(expected), .some(actual)):
            return MatcherResult(bool: areEquivalent(expected, actual), message: message)
        }
    }
}

/// Matches against an expected value using some comparator, displaying mismatches in a user-readable form.
public func equalDiff<T>(_ expectedValue: T?, by areEquivalent: @escaping (T, T) -> Bool) -> Matcher<T> {
    // Borrowed from https://github.com/krzysztofzablocki/Difference
    Matcher.define("equal <\(stringify(expectedValue))>") { actualExpression, message in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (.none, .some):
            return MatcherResult(status: .fail, message: message.appendedBeNilHint())
        case (_, .none):
            return MatcherResult(status: .fail, message: message)
        case let (.some(expected), .some(actual)):
            return MatcherResult(
                bool: areEquivalent(expected, actual),
                message: ExpectationMessage.fail("")
            )
        }
    }
}

/// Matches against an expected equatable value, displaying mismatches in a user-readable form.
public func equalDiff<T>(_ expectedValue: T?) -> Matcher<T> where T: Equatable {
    equalDiff(expectedValue, by: ==)
}

/// Matches close signed numeric values up to a given tolerance.
public func beCloseTo<Value>(
    _ expectedValue: Value,
    within delta: Value = 1
) -> Matcher<Value> where Value: SignedNumeric & Comparable {
    let message = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
    return Matcher.define { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return MatcherResult(
            bool: actualValue != nil && abs(actualValue! - expectedValue) < delta,
            message: .expectedCustomValueTo(message, actual: "<\(stringify(actualValue))>")
        )
    }
}
