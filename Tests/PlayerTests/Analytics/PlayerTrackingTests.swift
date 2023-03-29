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
        let publisher = GenericTrackerMock<String>.StatePublisher()

        expectAtLeastEqualPublished(
            values: [.initialized, .updated("title")],
            from: publisher
        ) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    metadata: AssetMetadataMock(title: "title"),
                    trackerAdapters: [
                        GenericTrackerMock.adapter(statePublisher: publisher) { $0.title }
                    ]
                )
            )
            player.play()
        }
    }

    func testTrackingEnabledDuringThePlayback() {
        let player = Player()
        player.isTrackingEnabled = false

        let publisher = GenericTrackerMock<String>.StatePublisher()

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
                        GenericTrackerMock.adapter(statePublisher: publisher) { $0.title }
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

    func testTrackingDisabledDuringThePlayback() {
        let player = Player()
        player.isTrackingEnabled = true

        let publisher = GenericTrackerMock<String>.StatePublisher()

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
                        GenericTrackerMock.adapter(statePublisher: publisher) { $0.title }
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
        let publisher = EmptyTrackerMock.StatePublisher()

        let player = Player(item: .simple(url: Stream.shortOnDemand.url, trackerAdapters: [EmptyTrackerMock.adapter(statePublisher: publisher)]))
        player.isTrackingEnabled = true

        expectNothingPublished(from: publisher, during: .seconds(1)) {
            player.isTrackingEnabled = true
        }
    }
}
