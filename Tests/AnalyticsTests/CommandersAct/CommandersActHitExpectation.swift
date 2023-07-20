//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation

/// Describes a Commanders Act stream hit expectation.
struct CommandersActHitExpectation {
    private let name: CommandersActHit.Name
    private let evaluate: (CommandersActLabels) -> Void

    static func match(hit: CommandersActHit, with expectation: Self) -> Bool {
        guard hit.name == expectation.name else { return false }
        expectation.evaluate(hit.labels)
        return true
    }

    /// Play.
    static func play(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .play, evaluate: evaluate)
    }

    /// Pause.
    static func pause(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .pause, evaluate: evaluate)
    }

    /// Seek.
    static func seek(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .seek, evaluate: evaluate)
    }

    /// Stop.
    static func stop(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .stop, evaluate: evaluate)
    }

    /// End.
    static func eof(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .eof, evaluate: evaluate)
    }

    /// Pos.
    static func pos(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .pos, evaluate: evaluate)
    }

    /// Uptime.
    static func uptime(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .uptime, evaluate: evaluate)
    }

    /// Page view.
    static func page_view(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .page_view, evaluate: evaluate)
    }

    /// Custom event.
    static func custom(name: String, evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .custom(name), evaluate: evaluate)
    }
}

extension CommandersActHitExpectation: CustomDebugStringConvertible {
    var debugDescription: String {
        name.rawValue
    }
}
