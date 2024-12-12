//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxCircumspect
import PillarboxStreams

final class PlayerItemTrackerLifeCycleTests: TestCase {
    func testWithShortLivedPlayer() {
        let publisher = PlayerItemTrackerMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .deinitialized], from: publisher) {
            _ = PlayerItem.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [PlayerItemTrackerMock.adapter(statePublisher: publisher)]
            )
        }
    }

    func testItemPlayback() {
        let player = Player()
        let publisher = PlayerItemTrackerMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvents, .metricEvents], from: publisher) {
            player.append(.simple(
                url: Stream.onDemand.url,
                trackerAdapters: [PlayerItemTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testItemEntirePlayback() {
        let player = Player()
        let publisher = PlayerItemTrackerMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvents, .metricEvents, .disabled], from: publisher) {
            player.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [PlayerItemTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testDisableDuringDeinitPlayer() {
        var player: Player? = Player()
        let publisher = PlayerItemTrackerMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .disabled], from: publisher) {
            player?.append(.simple(
                url: Stream.shortOnDemand.url,
                trackerAdapters: [PlayerItemTrackerMock.adapter(statePublisher: publisher)]
            ))
            player = nil
        }
    }

    func testNetworkLoadedItemEntirePlayback() {
        let player = Player()
        let publisher = PlayerItemTrackerMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvents, .metricEvents, .disabled], from: publisher) {
            player.append(.mock(
                url: Stream.shortOnDemand.url,
                loadedAfter: 1,
                trackerAdapters: [PlayerItemTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testFailedItem() {
        let player = Player()
        let publisher = PlayerItemTrackerMock.StatePublisher()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvents, .metricEvents], from: publisher) {
            player.append(.simple(
                url: Stream.unavailable.url,
                trackerAdapters: [PlayerItemTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
    }

    func testMoveCurrentItem() {
        let publisher = PlayerItemTrackerMock.StatePublisher()
        let player = Player()
        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvents, .metricEvents], from: publisher) {
            player.append(.simple(
                url: Stream.onDemand.url,
                trackerAdapters: [PlayerItemTrackerMock.adapter(statePublisher: publisher)]
            ))
            player.play()
        }
        expectNothingPublished(from: publisher, during: .seconds(1)) {
            player.prepend(.simple(url: Stream.onDemand.url))
        }
    }
}
