//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation

/// Describes a Commanders Act stream event expectation.
struct CommandersActEventExpectation {
    private let name: CommandersActEvent.Name
    private let evaluate: (CommandersActLabels) -> Void

    static func match(event: CommandersActEvent, with expectation: CommandersActEventExpectation) -> Bool {
        guard event.name == expectation.name else { return false }
        expectation.evaluate(event.labels)
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

    /// Page view.
    static func page_view(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .page_view, evaluate: evaluate)
    }

    /// Hidden event
    static func hidden_event(evaluate: @escaping (CommandersActLabels) -> Void = { _ in }) -> Self {
        .init(name: .hidden_event, evaluate: evaluate)
    }
}

extension CommandersActEventExpectation: CustomDebugStringConvertible {
    var debugDescription: String {
        name.rawValue
    }
}
