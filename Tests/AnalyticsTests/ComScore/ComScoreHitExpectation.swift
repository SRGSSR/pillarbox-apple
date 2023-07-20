//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation

/// Describes a comScore stream hit expectation.
struct ComScoreHitExpectation {
    private let name: ComScoreHit.Name
    private let evaluate: (ComScoreLabels) -> Void

    static func match(hit: ComScoreHit, with expectation: Self) -> Bool {
        guard hit.name == expectation.name else { return false }
        expectation.evaluate(hit.labels)
        return true
    }

    /// Play.
    static func play(evaluate: @escaping (ComScoreLabels) -> Void = { _ in }) -> Self {
        .init(name: .play, evaluate: evaluate)
    }

    /// Pause.
    static func pause(evaluate: @escaping (ComScoreLabels) -> Void = { _ in }) -> Self {
        .init(name: .pause, evaluate: evaluate)
    }

    /// End.
    static func end(evaluate: @escaping (ComScoreLabels) -> Void = { _ in }) -> Self {
        .init(name: .end, evaluate: evaluate)
    }

    /// View.
    static func view(evaluate: @escaping (ComScoreLabels) -> Void = { _ in }) -> Self {
        .init(name: .view, evaluate: evaluate)
    }
}

extension ComScoreHitExpectation: CustomDebugStringConvertible {
    var debugDescription: String {
        name.rawValue
    }
}
