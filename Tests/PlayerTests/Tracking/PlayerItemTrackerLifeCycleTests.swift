//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxCircumspect
import PillarboxStreams

final class PlayerItemTrackerLifeCycleTests: TestCase {
    func testPlayerItemLifeCycle() {
        let publisher = TrackerLifeCycleMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: publisher) {
            _ = PlayerItem.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [TrackerLifeCycleMock.adapter(statePublisher: publisher)]
            )
        }
    }

    func testItemPlayback() {
        let player = Player()
        let publisher = TrackerLifeCycleMock.StatePublisher()
        expectEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent], from: publisher, during: .seconds(2)) {
            player.append(.simple(
                url: Stream.onDemand.url,
                trackerAdapters: [TrackerLifeCycleMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testItemEntirePlayback() {
        let player = Player()
        let publisher = TrackerLifeCycleMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent, .disabled], from: publisher) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [TrackerLifeCycleMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testDisableDuringDeinitPlayer() {
        var player: Player? = Player()
        let publisher = TrackerLifeCycleMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: publisher) {
            player?.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [TrackerLifeCycleMock.adapter(statePublisher: publisher)]
            ))
            player = nil
        }
    }

    func testNetworkLoadedItemEntirePlayback() {
        let player = Player()
        let publisher = TrackerLifeCycleMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent, .disabled], from: publisher) {
            player.append(.mock(
                url: Stream.shortOnDemand.url,
                loadedAfter: 1,
                trackerAdapters: [TrackerLifeCycleMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testFailedItem() {
        let player = Player()
        let publisher = TrackerLifeCycleMock.StatePublisher()
        expectEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent], from: publisher, during: .milliseconds(500)) {
            player.append(.simple(
                url: Stream.unavailable.url,
                trackerAdapters: [TrackerLifeCycleMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testMoveCurrentItem() {
        let publisher = TrackerLifeCycleMock.StatePublisher()
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvent, .metricEvent], from: publisher) {
            player.append(.simple(
                url: Stream.onDemand.url,
                trackerAdapters: [TrackerLifeCycleMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
        expectNothingPublished(from: publisher, during: .seconds(1)) {
            player.prepend(.simple(url: Stream.onDemand.url))
        }
    }
}
