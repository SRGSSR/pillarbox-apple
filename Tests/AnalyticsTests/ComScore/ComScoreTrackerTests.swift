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

// Testing comScore end events is a bit tricky:
//   1. Apparently comScore will never emit events if a play event is followed by an end event within ~5 seconds. For
//      this reason all tests checking end events must wait ~5 seconds after a play event.
//   2. End events are emitted automatically to close a session if the `SCORStreamingAnalytics` is destroyed. In this
//      case, and since we are not notifying the end event ourselves, we cannot customize its labels directly.
//      Fortunately we can customize them indirectly since the end event inherits labels from a former event. Thus,
//      to test end events resulting from tracker deallocation we need to have another event sent within the same
//      expectation so that the end event is provided a listener identifier.
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
            // See 1. at the top of this file.
            url: Stream.mediumOnDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectAtLeastEvents(
            .play(),
            .end { labels in
                expect(labels.ns_st_po).to(beCloseTo(Stream.mediumOnDemand.duration.seconds, within: 0.5))
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
            // See 2. at the top of this file.
            player?.play()
            // See 1. at the top of this file.
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

    func testDisableTrackingDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        expectAtLeastEvents(.play(), .end()) {
            // See 2. at the top of this file.
            player.play()
            // See 1. at the top of this file.
            expect(player.time.seconds).toEventually(beGreaterThan(5))
            player.isTrackingEnabled = false
        }
    }

    func testEnableTrackingDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                ComScoreTracker.adapter { _ in ["meta": "data"] }
            ]
        ))

        player.isTrackingEnabled = false

        expectNoEvents(during: .seconds(2)) {
            player.play()
        }

        expectAtLeastEvents(.play()) {
            player.isTrackingEnabled = true
        }
    }
}
