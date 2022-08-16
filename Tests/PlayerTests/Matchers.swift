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

/// Return `true` iff states are similar (up to associated values).
func areSimilar(lhsState: Player.ItemState, rhsState: Player.ItemState) -> Bool {
    switch (lhsState, rhsState) {
    case (.unknown, .unknown):
        return true
    case (.readyToPlay, .readyToPlay):
        return true
    case (.ended, .ended):
        return true
    case (.failed, .failed):
        return true
    default:
        return false
    }
}

/// Return `true` iff state arrays are similar (up to associated values).
func areSimilar(lhsStates: [Player.ItemState], rhsStates: [Player.ItemState]) -> Bool {
    guard lhsStates.count == rhsStates.count else { return false }
    for (lhsState, rhsState) in zip(lhsStates, rhsStates) where !areSimilar(lhsState: lhsState, rhsState: rhsState) {
        return false
    }
    return true
}

/// Match for similarity against an expected value.
public func beSimilarTo(_ expectedValue: Player.ItemState) -> Predicate<Player.ItemState> {
    equal(expectedValue, by: areSimilar)
}

/// Return `true` iff states are similar (up to associated values).
func areSimilar(lhsState: Player.State, rhsState: Player.State) -> Bool {
    switch (lhsState, rhsState) {
    case (.idle, .idle),
        (.playing, .playing),
        (.paused, .paused),
        (.ended, .ended),
        (.failed, .failed):
        return true
    default:
        return false
    }
}

/// Return `true` iff states are similar (up to associated values).
func areSimilar(lhsStates: [Player.State], rhsStates: [Player.State]) -> Bool {
    guard lhsStates.count == rhsStates.count else { return false }
    for (lhsState, rhsState) in zip(lhsStates, rhsStates) where !areSimilar(lhsState: lhsState, rhsState: rhsState) {
        return false
    }
    return true
}

/// Match for similarity against an expected value.
public func beSimilarTo(_ expectedValue: Player.State) -> Predicate<Player.State> {
    equal(expectedValue, by: areSimilar)
}
