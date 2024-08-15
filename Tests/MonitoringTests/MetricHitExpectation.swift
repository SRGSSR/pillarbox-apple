//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

private struct _MetricHitExpectation<Data>: MetricHitExpectation where Data: Encodable {
    let eventName: EventName
    private let evaluate: (MetricPayload<Data>) -> Void

    init(eventName: EventName, evaluate: @escaping (MetricPayload<Data>) -> Void) {
        self.eventName = eventName
        self.evaluate = evaluate
    }

    func evaluate(_ data: MetricPayload<Data>) {
        evaluate(data)
    }
}

protocol MetricHitExpectation {
    associatedtype Data: Encodable

    var eventName: EventName { get }

    func evaluate(_ data: MetricPayload<Data>)
}

private extension MetricHitExpectation {
    func match(payload: any Encodable, with expectation: any MetricHitExpectation) -> Bool {
        guard let payload = payload as? MetricPayload<Data>, payload.eventName == expectation.eventName else {
            return false
        }
        evaluate(payload)
        return true
    }
}

extension _MetricHitExpectation: CustomDebugStringConvertible {
    var debugDescription: String {
        eventName.rawValue
    }
}

func match(payload: any Encodable, with expectation: any MetricHitExpectation) -> Bool {
    expectation.match(payload: payload, with: expectation)
}

extension MonitoringTestCase {
    func error(evaluate: @escaping (MetricPayload<MetricErrorData>) -> Void = { _ in }) -> some MetricHitExpectation {
        _MetricHitExpectation(eventName: .error, evaluate: evaluate)
    }

    func heartbeat(evaluate: @escaping (MetricPayload<MetricStatusEventData>) -> Void = { _ in }) -> some MetricHitExpectation {
        _MetricHitExpectation(eventName: .heartbeat, evaluate: evaluate)
    }

    func start(evaluate: @escaping (MetricPayload<MetricStartData>) -> Void = { _ in }) -> some MetricHitExpectation {
        _MetricHitExpectation(eventName: .start, evaluate: evaluate)
    }

    func stop(evaluate: @escaping (MetricPayload<MetricStatusEventData>) -> Void = { _ in }) -> some MetricHitExpectation {
        _MetricHitExpectation(eventName: .stop, evaluate: evaluate)
    }
}
