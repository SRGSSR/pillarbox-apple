//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import PillarboxAnalytics

/// Describes a Commanders Act stream hit expectation.
struct CommandersActHitExpectation {
    private let name: CommandersActHit.Name
    private let evaluate: (CommandersActLabels) -> Void

    fileprivate init(name: CommandersActHit.Name, evaluate: @escaping (CommandersActLabels) -> Void) {
        self.name = name
        self.evaluate = evaluate
    }

    static func match(hit: CommandersActHit, with expectation: Self) -> Bool {
        guard hit.name == expectation.name else { return false }
        expectation.evaluate(hit.labels)
        return true
    }
}

extension CommandersActHitExpectation: CustomDebugStringConvertible {
    var debugDescription: String {
        name.rawValue
    }
}

extension CommandersActTestCase {
    func play(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> CommandersActHitExpectation {
        CommandersActHitExpectation(name: .play, evaluate: evaluate)
    }

    func pause(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> CommandersActHitExpectation {
        CommandersActHitExpectation(name: .pause, evaluate: evaluate)
    }

    func seek(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> CommandersActHitExpectation {
        CommandersActHitExpectation(name: .seek, evaluate: evaluate)
    }

    func stop(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> CommandersActHitExpectation {
        CommandersActHitExpectation(name: .stop, evaluate: evaluate)
    }

    func eof(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> CommandersActHitExpectation {
        CommandersActHitExpectation(name: .eof, evaluate: evaluate)
    }

    func pos(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> CommandersActHitExpectation {
        CommandersActHitExpectation(name: .pos, evaluate: evaluate)
    }

    func uptime(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> CommandersActHitExpectation {
        CommandersActHitExpectation(name: .uptime, evaluate: evaluate)
    }

    func page_view(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> CommandersActHitExpectation {
        CommandersActHitExpectation(name: .page_view, evaluate: evaluate)
    }

    func custom(name: String, evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> CommandersActHitExpectation {
        CommandersActHitExpectation(name: .custom(name), evaluate: evaluate)
    }
}
