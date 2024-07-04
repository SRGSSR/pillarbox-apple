//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import PillarboxCircumspect

final class MetricLogTests: TestCase {
    func testEmpty() {
        let metricLog = MetricLog()
        expectNothingPublished(from: metricLog.eventsPublisher(), during: .milliseconds(100))
    }

    func testOneEvent() {
        let metricLog = MetricLog()
        let event = MetricEvent(kind: .assetLoading(.init()))
        expectSimilarPublished(values: [event], from: metricLog.eventsPublisher(), during: .milliseconds(100)) {
            metricLog.addEvent(event)
        }
    }

    func testManyEvents() {
        let metricLog = MetricLog()
        let event1 = MetricEvent(kind: .assetLoading(.init()))
        let event2 = MetricEvent(kind: .resourceLoading(.init()))
        expectSimilarPublished(values: [event1, event2], from: metricLog.eventsPublisher(), during: .milliseconds(100)) {
            metricLog.addEvent(event1)
            metricLog.addEvent(event2)
        }
    }

    func testWithPreviousEvent() {
        let metricLog = MetricLog()
        let event1 = MetricEvent(kind: .assetLoading(.init()))
        let event2 = MetricEvent(kind: .resourceLoading(.init()))
        metricLog.addEvent(event1)
        metricLog.addEvent(event2)
        expectSimilarPublished(values: [event1, event2], from: metricLog.eventsPublisher(), during: .milliseconds(100))
    }
}
