//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import CoreMedia
import Nimble

extension PlaybackState: Similar {
    /// Similarity ignores associated values
    public static func ~= (lhs: PlaybackState, rhs: PlaybackState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.playing, .playing), (.paused, .paused), (.ended, .ended), (.failed, .failed):
            return true
        default:
            return false
        }
    }
}

func beClose(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
    Time.close(within: tolerance)
}

func beClose(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
    Time.close(within: tolerance)
}

/// Match against an expected value using some comparator.
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
