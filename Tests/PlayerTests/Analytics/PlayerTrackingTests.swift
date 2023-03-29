//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@testable import Player

import Circumspect
import Combine

final class PlayerTrackingTests: TestCase {
    func testTrackingDisabled() {
        let player = Player()
        player.isTrackingEnabled = false
        let publisher = TrackerMock<String>.StatePublisher()

        expectAtLeastEqualPublished(
            values: [.initialized, .updated("title")],
            from: publisher
        ) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    metadata: AssetMetadataMock(title: "title"),
                    trackerAdapters: [
                        TrackerMock.adapter(statePublisher: publisher) { $0.title }
                    ]
                )
            )
            player.play()
        }
    }

    func testTrackingEnabledDuringPlayback() {
        let player = Player()
        player.isTrackingEnabled = false

        let publisher = TrackerMock<String>.StatePublisher()

        expectEqualPublished(
            values: [.initialized, .updated("title")],
            from: publisher,
            during: .seconds(1)
        ) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    metadata: AssetMetadataMock(title: "title"),
                    trackerAdapters: [
                        TrackerMock.adapter(statePublisher: publisher) { $0.title }
                    ]
                )
            )
        }

        expectAtLeastEqualPublished(
            values: [.enabled, .disabled],
            from: publisher
        ) {
            player.isTrackingEnabled = true
            player.play()
        }
    }

    func testTrackingDisabledDuringPlayback() {
        let player = Player()
        player.isTrackingEnabled = true

        let publisher = TrackerMock<String>.StatePublisher()

        expectEqualPublished(
            values: [.initialized, .enabled, .updated("title")],
            from: publisher,
            during: .seconds(1)
        ) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    metadata: AssetMetadataMock(title: "title"),
                    trackerAdapters: [
                        TrackerMock.adapter(statePublisher: publisher) { $0.title }
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
        let publisher = NoMetadataTrackerMock.StatePublisher()

        let player = Player(item: .simple(url: Stream.shortOnDemand.url, trackerAdapters: [NoMetadataTrackerMock.adapter(statePublisher: publisher)]))
        player.isTrackingEnabled = true

        expectNothingPublished(from: publisher, during: .seconds(1)) {
            player.isTrackingEnabled = true
        }
    }
}
