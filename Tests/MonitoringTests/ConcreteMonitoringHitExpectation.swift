//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

private struct ConcreteMonitoringHitExpectation<Data>: MonitoringHitExpectation where Data: Encodable {
    let eventName: EventName
    private let evaluate: (Data) -> Void

    init(eventName: EventName, evaluate: @escaping (Data) -> Void) {
        self.eventName = eventName
        self.evaluate = evaluate
    }

    func evaluate(_ data: Data) {
        evaluate(data)
    }
}

// TODO: Same for comScore / Commanders Act to have consistent syntax without dot
extension MonitoringTestCase {
    func start(evaluate: @escaping (MetricStartData) -> Void = { _ in }) -> some MonitoringHitExpectation {
        ConcreteMonitoringHitExpectation(eventName: .start, evaluate: evaluate)
    }

    func error(evaluate: @escaping (MetricErrorData) -> Void = { _ in }) -> some MonitoringHitExpectation {
        ConcreteMonitoringHitExpectation(eventName: .error, evaluate: evaluate)
    }

    func event(name: EventName, evaluate: @escaping (MetricEventData) -> Void = { _ in }) -> some MonitoringHitExpectation {
        ConcreteMonitoringHitExpectation(eventName: name, evaluate: evaluate)
    }
}
