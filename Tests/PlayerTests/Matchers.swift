//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player
import Nimble

/// Match against an expected value using some comparator
/// Directly borrowed from https://github.com/Quick/Nimble/blob/main/Sources/Nimble/Matchers/Equal.swift
func equal<T>(_ expectedValue: T?, by areEquivalent: @escaping (T, T) -> Bool) -> Predicate<T> {
    Predicate.define("equal <\(stringify(expectedValue))>") { actualExpression, message in
        let actualValue = try actualExpression.evaluate()
        switch (expectedValue, actualValue) {
        case (nil, _?):
            return PredicateResult(status: .fail, message: message.appendedBeNilHint())
        case (_, nil):
            return PredicateResult(status: .fail, message: message)
        case let (expected?, actual?):
            let matches = areEquivalent(expected, actual)
            return PredicateResult(bool: matches, message: message)
        }
    }
}
