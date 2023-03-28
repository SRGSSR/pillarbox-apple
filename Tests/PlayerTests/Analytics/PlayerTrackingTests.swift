//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

@testable import Player

import Circumspect

final class PlayerTrackingTests: TestCase {
    func testTrackingDisabled() {
        let player = Player()
        player.isTrackingEnabled = false

        expectAtLeastEqualPublished(
            values: [.initialized, .updated("title")],
            from: NonConfigurableTrackerMock.state
        ) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    metadata: AssetMetadataMock(title: "title"),
                    trackerAdapters: [NonConfigurableTrackerMock.adapter { $0.title } ]
                )
            )
            player.play()
        }
    }

    func testTrackingEnabledDuringThePlayback() {
        let player = Player()
        player.isTrackingEnabled = false

        expectEqualPublished(
            values: [.initialized, .updated("title")],
            from: NonConfigurableTrackerMock.state,
            during: .seconds(1)
        ) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    metadata: AssetMetadataMock(title: "title"),
                    trackerAdapters: [NonConfigurableTrackerMock.adapter { $0.title } ]
                )
            )
        }

        expectAtLeastEqualPublished(
            values: [.enabled, .disabled],
            from: NonConfigurableTrackerMock.state
        ) {
            player.isTrackingEnabled = true
            player.play()
        }
    }

    func testTrackingDisabledDuringThePlayback() {
        let player = Player()
        player.isTrackingEnabled = true

        expectEqualPublished(
            values: [.initialized, .enabled, .updated("title")],
            from: NonConfigurableTrackerMock.state,
            during: .seconds(1)
        ) {
            player.append(
                .simple(
                    url: Stream.shortOnDemand.url,
                    metadata: AssetMetadataMock(title: "title"),
                    trackerAdapters: [NonConfigurableTrackerMock.adapter { $0.title } ]
                )
            )
        }

        expectAtLeastEqualPublished(
            values: [.disabled],
            from: NonConfigurableTrackerMock.state
        ) {
            player.isTrackingEnabled = false
            player.play()
        }
    }

    func testTrackingEnabledTwice() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url, trackerAdapters: [SimpleTrackerMock.adapter()]))
        player.isTrackingEnabled = true

        expectNothingPublished(from: SimpleTrackerMock.state, during: .seconds(1)) {
            player.isTrackingEnabled = true
        }
    }
}
