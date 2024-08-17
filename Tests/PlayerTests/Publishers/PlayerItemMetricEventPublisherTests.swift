//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxStreams

final class PlayerItemMetricEventPublisherTests: TestCase {
    func testPlayableItemMetricEvent() {
        let item = PlayerItem.mock(url: Stream.onDemand.url, loadedAfter: 0.1)
        expectOnlySimilarPublished(
            values: [.anyMetadataReady],
            from: item.metricEventPublisher()
        ) {
            PlayerItem.load(for: item.id)
        }
    }

    func testFailingItemMetricEvent() {
        let item = PlayerItem.failing(loadedAfter: 0.1)
        expectNothingPublished(from: item.metricEventPublisher(), during: .milliseconds(500)) {
            PlayerItem.load(for: item.id)
        }
    }
}
