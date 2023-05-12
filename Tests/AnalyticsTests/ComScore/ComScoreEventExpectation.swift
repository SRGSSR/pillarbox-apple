//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation

/// Describes a comScore stream event expectation.
struct ComScoreEventExpectation {
    private let name: ComScoreEvent.Name
    private let evaluate: (ComScoreLabels) -> Void

    static func match(event: ComScoreEvent, with expectation: Self) -> Bool {
        guard event.name == expectation.name else { return false }
        expectation.evaluate(event.labels)
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

extension ComScoreEventExpectation: CustomDebugStringConvertible {
    var debugDescription: String {
        name.rawValue
    }
}
