//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Difference
import Nimble

/// Matches against an expected value using some comparator.
public func equal<T>(_ expectedValue: T?, by areEquivalent: @escaping (T, T) -> Bool) -> Predicate<T> {
    // Directly borrowed from https://github.com/Quick/Nimble/blob/main/Sources/Nimble/Matchers/Equal.swift
    Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, message in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (.none, .some):
            return PredicateResult(status: .fail, message: message.appendedBeNilHint())
        case (_, .none):
            return PredicateResult(status: .fail, message: message)
        case let (.some(expected), .some(actual)):
            let matches = areEquivalent(expected, actual)
            return PredicateResult(bool: matches, message: message)
        }
    }
}

/// Matches against an expected value using some comparator, displaying mismatches in a user-readable form.
public func equalDiff<T>(_ expectedValue: T?, by areEquivalent: @escaping (T, T) -> Bool) -> Predicate<T> {
    // Borrowed from https://github.com/krzysztofzablocki/Difference
    Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, message in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (.none, .some):
            return PredicateResult(status: .fail, message: message.appendedBeNilHint())
        case (_, .none):
            return PredicateResult(status: .fail, message: message)
        case let (.some(expected), .some(actual)):
            return PredicateResult(
                bool: areEquivalent(expected, actual),
                message: ExpectationMessage.fail(diff(expectedValue, actualValue).joined(separator: ", "))
            )
        }
    }
}

/// Matches against an expected equatable value, displaying mismatches in a user-readable form.
public func equalDiff<T>(_ expectedValue: T?) -> Predicate<T> where T: Equatable {
    equalDiff(expectedValue, by: ==)
}

/// Matches close signed numeric values up to a given tolerance.
public func beCloseTo<Value: SignedNumeric & Comparable>(
    _ expectedValue: Value,
    within delta: Value = 1
) -> Predicate<Value> {
    let message = "be close to <\(stringify(expectedValue))> (within \(stringify(delta)))"
    return Predicate.define { actualExpression in
        let actualValue = try actualExpression.evaluate()
        return PredicateResult(
            bool: actualValue != nil && abs(actualValue! - expectedValue) < delta,
            message: .expectedCustomValueTo(message, actual: "<\(stringify(actualValue))>")
        )
    }
}
