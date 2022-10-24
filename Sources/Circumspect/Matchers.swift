//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Difference
import Nimble

/// Match against an expected value using some comparator.
/// Directly borrowed from https://github.com/Quick/Nimble/blob/main/Sources/Nimble/Matchers/Equal.swift
public func equal<T>(_ expectedValue: T?, by areEquivalent: @escaping (T, T) -> Bool) -> Predicate<T> {
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

/// Nimble matcher displaying mismatches in a friendly way.
/// Borrowed from https://github.com/krzysztofzablocki/Difference
public func equalDiff<T>(_ expectedValue: T?, by areEquivalent: @escaping (T, T) -> Bool) -> Predicate<T> {
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

/// Nimble matcher displaying equality differences in a friendly way.
public func equalDiff<T: Equatable>(_ expectedValue: T?) -> Predicate<T> {
    equalDiff(expectedValue, by: ==)
}
