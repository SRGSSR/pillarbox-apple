//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import PillarboxCircumspect
import PillarboxStreams

final class PlayerTrackingTests: TestCase {
    func testTrackingDisabled() {
        let player = Player()
        player.isTrackingEnabled = false
        let publisher = PlayerItemTrackerMock.StatePublisher()

        expectAtLeastEqualPublished(values: [.initialized], from: publisher) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    trackerAdapters: [
                        PlayerItemTrackerMock.adapter(statePublisher: publisher)
                    ]
                )
            )
            player.play()
        }
    }

    func testTrackingEnabledDuringPlayback() {
        let player = Player()
        player.isTrackingEnabled = false

        let publisher = PlayerItemTrackerMock.StatePublisher()

        expectAtLeastEqualPublished(values: [.initialized], from: publisher) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    trackerAdapters: [
                        PlayerItemTrackerMock.adapter(statePublisher: publisher)
                    ]
                )
            )
        }

        expectAtLeastEqualPublished(
            values: [.enabled, .metricEvents, .disabled],
            from: publisher
        ) {
            player.isTrackingEnabled = true
            player.play()
        }
    }

    func testTrackingDisabledDuringPlayback() {
        let player = Player()
        player.isTrackingEnabled = true

        let publisher = PlayerItemTrackerMock.StatePublisher()

        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvents, .metricEvents], from: publisher) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    trackerAdapters: [
                        PlayerItemTrackerMock.adapter(statePublisher: publisher)
                    ]
                )
            )
        }

        expectAtLeastEqualPublished(
            values: [.disabled],
            from: publisher
        ) {
            player.isTrackingEnabled = false
            player.play()
        }
    }

    func testTrackingEnabledTwice() {
        let publisher = PlayerItemTrackerMock.StatePublisher()

        let player = Player(item: .simple(url: Stream.shortOnDemand.url, trackerAdapters: [PlayerItemTrackerMock.adapter(statePublisher: publisher)]))
        player.isTrackingEnabled = true

        expectAtLeastEqualPublished(values: [.metricEvents, .metricEvents], from: publisher) {
            player.isTrackingEnabled = true
        }
    }

    func testMandatoryTracker() {
        let player = Player()
        player.isTrackingEnabled = false

        let publisher = PlayerItemTrackerMock.StatePublisher()

        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvents, .metricEvents], from: publisher) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    trackerAdapters: [
                        PlayerItemTrackerMock.adapter(statePublisher: publisher, behavior: .mandatory)
                    ]
                )
            )
        }
    }

    func testEnablingTrackingMustNotEmitMetricEventsAgainForMandatoryTracker() {
        let player = Player()
        player.isTrackingEnabled = false

        let publisher = PlayerItemTrackerMock.StatePublisher()

        expectAtLeastEqualPublished(values: [.initialized, .enabled, .metricEvents, .metricEvents], from: publisher) {
            player.append(
                .simple(
                    url: Stream.onDemand.url,
                    trackerAdapters: [
                        PlayerItemTrackerMock.adapter(statePublisher: publisher, behavior: .mandatory)
                    ]
                )
            )
        }

        expectNothingPublished(from: publisher, during: .seconds(1)) {
            player.isTrackingEnabled = true
        }
    }
}
