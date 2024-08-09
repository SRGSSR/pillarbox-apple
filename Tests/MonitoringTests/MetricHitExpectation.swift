//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxMonitoring

protocol MetricHitExpectation {
    associatedtype Data: Encodable

    var eventName: EventName { get }

    func evaluate(_ data: Data)
}

extension MetricHitExpectation {
    func match(payload: any Encodable, with expectation: any MetricHitExpectation) -> Bool {
        guard let payload = payload as? MetricPayload<Data>, payload.eventName == expectation.eventName else {
            return false
        }
        evaluate(payload.data)
        return true
    }
}

func match(payload: any Encodable, with expectation: any MetricHitExpectation) -> Bool {
    expectation.match(payload: payload, with: expectation)
}
