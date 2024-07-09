//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import Nimble
import PillarboxCircumspect

final class MetricLogTests: TestCase {
    func testEmpty() {
        let metricLog = MetricLog()
        expectNothingPublished(from: metricLog.eventPublisher(), during: .milliseconds(100))
    }

    func testAppend() {
        let metricLog = MetricLog()
        let event = MetricEvent(kind: .assetLoading(.init()))
        expectSimilarPublished(values: [event], from: metricLog.eventPublisher(), during: .milliseconds(100)) {
            metricLog.appendEvent(event)
            expect(metricLog.events).to(beSimilarTo([event]))
        }
    }
}
