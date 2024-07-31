//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxCircumspect
import PillarboxStreams

final class PlayerItemTrackerMetricLifeCycleTests: TestCase {
    func testItemPlayback() {
        let player = Player()
        let publisher = TrackerMetricEventMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent], from: publisher) {
            player.append(.simple(
                url: Stream.onDemand.url,
                trackerAdapters: [TrackerMetricEventMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testItemEntirePlayback() {
        let player = Player()
        let publisher = TrackerMetricEventMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent, .disabled], from: publisher) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [TrackerMetricEventMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testNetworkLoadedItemEntirePlayback() {
        let player = Player()
        let publisher = TrackerMetricEventMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent, .disabled], from: publisher) {
            player.append(.mock(
                url: Stream.shortOnDemand.url,
                loadedAfter: 1,
                trackerAdapters: [TrackerMetricEventMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testFailedItem() {
        let player = Player()
        let publisher = TrackerMetricEventMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent], from: publisher) {
            player.append(.simple(
                url: Stream.unavailable.url,
                trackerAdapters: [TrackerMetricEventMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testMoveCurrentItem() {
        let publisher = TrackerMetricEventMock.StatePublisher()
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent], from: publisher) {
            player.append(.simple(
                url: Stream.onDemand.url,
                trackerAdapters: [TrackerMetricEventMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
        expectNothingPublished(from: publisher, during: .seconds(1)) {
            player.prepend(.simple(url: Stream.onDemand.url))
        }
    }
}
