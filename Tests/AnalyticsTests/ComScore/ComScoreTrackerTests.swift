//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import ComScore
import CoreMedia
import Nimble
import Player
import Streams
import XCTest

private struct AssetMetadataMock: AssetMetadata {}

final class ComScoreTrackerTests: ComScoreTestCase {
    func testInitiallyPlaying() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.ns_st_po).to(equal(0))
            }
        ) {
            player.play()
        }
    }

    func testInitiallyPaused() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectNoEvents(during: .seconds(2)) {
            player.pause()
        }
    }

    func testPauseDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        player.play()
        expect(player.time.seconds).toEventually(beGreaterThan(1))

        expectAtLeastEvents(
            .pause { labels in
                expect(labels.ns_st_po).to(beCloseTo(1, within: 0.5))
            }
        ) {
            player.pause()
        }
    }

    func testPlaybackEnd() {
        let player = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectAtLeastEvents(
            .play(),
            .end { labels in
                expect(labels.ns_st_po).to(beCloseTo(1, within: 0.1))
            }
        ) {
            player.play()
        }
    }

    func testDestroyPlayerDuringPlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectAtLeastEvents(
            .play(),
            .end { labels in
                expect(labels.ns_st_po).to(beCloseTo(5, within: 0.1))
            }
        ) {
            // Ensure the listener identifier can be associated with the end event.
            player?.play()
            // We have to wait at least 5 seconds due to comScore behavior.
            expect(player?.time.seconds).toEventually(beGreaterThan(5))
            player = nil
        }
    }

    func testFailure() {
        let player = Player(item: .simple(
            url: Stream.unavailable.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectNoEvents(during: .seconds(3)) {
            player.play()
        }
    }

    func testDisableTracking() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectAtLeastEvents(
            .play(),
            .end()
        ) {
            // Ensure the listener identifier can be associated with the end event.
            player.play()
            // We have to wait at least 5 seconds due to comScore behavior.
            expect(player.time.seconds).toEventually(beGreaterThan(5))
            player.isTrackingEnabled = false
        }
    }
}
