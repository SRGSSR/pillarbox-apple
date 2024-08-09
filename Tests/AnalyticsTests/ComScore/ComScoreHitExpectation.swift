//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxAnalytics

/// Describes a comScore stream hit expectation.
struct ComScoreHitExpectation {
    private let name: ComScoreHit.Name
    private let evaluate: (ComScoreLabels) -> Void

    fileprivate init(name: ComScoreHit.Name, evaluate: @escaping (ComScoreLabels) -> Void) {
        self.name = name
        self.evaluate = evaluate
    }

    static func match(hit: ComScoreHit, with expectation: Self) -> Bool {
        guard hit.name == expectation.name else { return false }
        expectation.evaluate(hit.labels)
        return true
    }
}

extension ComScoreHitExpectation: CustomDebugStringConvertible {
    var debugDescription: String {
        name.rawValue
    }
}

extension ComScoreTestCase {
    func play(evaluate: @escaping (ComScoreLabels) -> Void = { _ in }) -> ComScoreHitExpectation {
        ComScoreHitExpectation(name: .play, evaluate: evaluate)
    }

    func playrt(evaluate: @escaping (ComScoreLabels) -> Void = { _ in }) -> ComScoreHitExpectation {
        ComScoreHitExpectation(name: .playrt, evaluate: evaluate)
    }

    func pause(evaluate: @escaping (ComScoreLabels) -> Void = { _ in }) -> ComScoreHitExpectation {
        ComScoreHitExpectation(name: .pause, evaluate: evaluate)
    }

    func end(evaluate: @escaping (ComScoreLabels) -> Void = { _ in }) -> ComScoreHitExpectation {
        ComScoreHitExpectation(name: .end, evaluate: evaluate)
    }

    func view(evaluate: @escaping (ComScoreLabels) -> Void = { _ in }) -> ComScoreHitExpectation {
        ComScoreHitExpectation(name: .view, evaluate: evaluate)
    }
}
