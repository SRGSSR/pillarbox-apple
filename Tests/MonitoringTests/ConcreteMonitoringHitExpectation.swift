//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

private struct _MetricHitExpectation<Data>: MetricHitExpectation where Data: Encodable {
    let eventName: EventName
    private let evaluate: (Data) -> Void

    fileprivate init(eventName: EventName, evaluate: @escaping (Data) -> Void) {
        self.eventName = eventName
        self.evaluate = evaluate
    }

    func evaluate(_ data: Data) {
        evaluate(data)
    }
}

extension MonitoringTestCase {
    func start(evaluate: @escaping (MetricStartData) -> Void = { _ in }) -> some MetricHitExpectation {
        _MetricHitExpectation(eventName: .start, evaluate: evaluate)
    }

    func error(evaluate: @escaping (MetricErrorData) -> Void = { _ in }) -> some MetricHitExpectation {
        _MetricHitExpectation(eventName: .error, evaluate: evaluate)
    }

    func event(name: EventName, evaluate: @escaping (MetricEventData) -> Void = { _ in }) -> some MetricHitExpectation {
        _MetricHitExpectation(eventName: name, evaluate: evaluate)
    }
}
