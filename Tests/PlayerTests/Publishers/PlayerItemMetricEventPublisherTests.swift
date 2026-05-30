//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxStreams

private struct MockError: Error {}

final class PlayerItemMetricEventPublisherTests: TestCase {
    func testPlayableItemMetricEvent() {
        let item = PlayerItem.playable(url: Stream.onDemand.url, after: 0.1)
        expectAtLeastSimilarPublished(
            values: [.anyMetadata],
            from: item.metricEventPublisher()
        ) {
            PlayerItem.load(for: item.id)
        }
    }

    func testFailingItemMetricEvent() {
        let item = PlayerItem.failing(with: MockError(), after: 0.1)
        expectNothingPublished(from: item.metricEventPublisher(), during: .milliseconds(500)) {
            PlayerItem.load(for: item.id)
        }
    }
}
