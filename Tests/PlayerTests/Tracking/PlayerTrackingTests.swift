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
        let publisher = TrackerLifeCycleMock.StatePublisher()

        expectEqualPublished(values: [.initialized], from: publisher, during: .milliseconds(500)) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    trackerAdapters: [
                        TrackerLifeCycleMock.adapter(statePublisher: publisher)
                    ]
                )
            )
            player.play()
        }
    }

    func testTrackingEnabledDuringPlayback() {
        let player = Player()
        player.isTrackingEnabled = false

        let publisher = TrackerLifeCycleMock.StatePublisher()

        expectEqualPublished(values: [.initialized], from: publisher, during: .seconds(1)) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    trackerAdapters: [
                        TrackerLifeCycleMock.adapter(statePublisher: publisher)
                    ]
                )
            )
        }

        expectAtLeastEqualPublished(
            values: [.enabled, .metricEvents, .metricEvents, .disabled],
            from: publisher
        ) {
            player.isTrackingEnabled = true
            player.play()
        }
    }

    func testTrackingDisabledDuringPlayback() {
        let player = Player()
        player.isTrackingEnabled = true

        let publisher = TrackerLifeCycleMock.StatePublisher()

        expectEqualPublished(values: [.initialized, .enabled, .metricEvents, .metricEvents], from: publisher, during: .seconds(1)) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    trackerAdapters: [
                        TrackerLifeCycleMock.adapter(statePublisher: publisher)
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
        let publisher = TrackerLifeCycleMock.StatePublisher()

        let player = Player(item: .simple(url: Stream.shortOnDemand.url, trackerAdapters: [TrackerLifeCycleMock.adapter(statePublisher: publisher)]))
        player.isTrackingEnabled = true

        expectEqualPublished(values: [.metricEvents, .metricEvents], from: publisher, during: .seconds(1)) {
            player.isTrackingEnabled = true
        }
    }
}
