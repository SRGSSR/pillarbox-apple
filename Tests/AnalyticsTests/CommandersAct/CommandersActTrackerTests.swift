//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import Player
import Streams
import XCTest

private struct AssetMetadataMock: AssetMetadata {}

final class CommandersActTrackerTests: CommandersActTestCase {
    func testInitiallyPlaying() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .onDemand)
                }
            ]
        ))

        expectAtLeastHits(
            .play { labels in
                expect(labels.media_position).to(equal(0))
            }
        ) {
            player.play()
        }
    }

    func testInitiallyPaused() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectNoHits(during: .seconds(2)) {
            player.pause()
        }
    }

    func testPauseDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .onDemand)
                }
            ]
        ))

        player.play()
        expect(player.time.seconds).toEventually(beGreaterThan(1))

        expectAtLeastHits(
            .pause { labels in
                expect(labels.media_position).to(equal(1))
            }
        ) {
            player.pause()
        }
    }

    func testPlaybackEnd() {
        let player = Player(item: .simple(
            url: Stream.mediumOnDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .onDemand)
                }
            ]
        ))

        expectAtLeastHits(
            .play(),
            .eof { labels in
                expect(labels.media_position).to(equal(Int(Stream.mediumOnDemand.duration.seconds)))
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
                CommandersActTracker.adapter { _ in
                    .test(streamType: .onDemand)
                }
            ]
        ))

        player?.play()
        expect(player?.time.seconds).toEventually(beGreaterThan(5))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(5))
            }
        ) {
            player = nil
        }
    }

    func testDestroyPlayerDuringPlaybackAtNonStandardPlaybackSpeed() {
        var player: Player? = Player(item: .simple(
            url: Stream.onDemand.url,
            metadata: AssetMetadataMock(),
            trackerAdapters: [
                CommandersActTracker.adapter { _ in
                    .test(streamType: .onDemand)
                }
            ]
        ))
        player?.setDesiredPlaybackSpeed(2)

        player?.play()
        expect(player?.time.seconds).toEventually(beGreaterThan(10))

        expectAtLeastHits(
            .stop { labels in
                expect(labels.media_position).to(equal(10))
            }
        ) {
            player = nil
        }
    }

    func testDestroyPlayerAfterPlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.shortOnDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectAtLeastHits(.play(), .eof()) {
            player?.play()
        }

        expectNoHits(during: .seconds(2)) {
            player = nil
        }
    }

    func testFailure() {
        let player = Player(item: .simple(
            url: Stream.unavailable.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectNoHits(during: .seconds(3)) {
            player.play()
        }
    }

    func testDisableTrackingDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player.play()
        expect(player.time.seconds).toEventually(beGreaterThan(5))

        expectAtLeastHits(.stop()) {
            player.isTrackingEnabled = false
        }
    }

    func testEnableTrackingDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player.isTrackingEnabled = false

        expectNoHits(during: .seconds(2)) {
            player.play()
        }

        expectAtLeastHits(.play()) {
            player.isTrackingEnabled = true
        }
    }
}
