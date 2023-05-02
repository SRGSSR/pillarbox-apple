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

final class CommandersActTrackerTests: CommandersActTestCase {
    func testMediaPlayerProperties() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_player_display).to(equal("Pillarbox"))
                expect(labels.media_player_version).notTo(beEmpty())
            }
        ) {
            player.play()
        }
    }

    func testInitiallyPlaying() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectAtLeastEvents(
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

        expectNoEvents(during: .seconds(2)) {
            player.pause()
        }
    }

    func testPauseDuringPlayback() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player.play()
        expect(player.time.seconds).toEventually(beGreaterThan(1))

        expectAtLeastEvents(
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
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectAtLeastEvents(
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
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player?.play()
        expect(player?.time.seconds).toEventually(beGreaterThan(5))

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(5))
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

        expectAtLeastEvents(.play(), .eof()) {
            player?.play()
        }

        expectNoEvents(during: .seconds(2)) {
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

        expectNoEvents(during: .seconds(3)) {
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

        expectAtLeastEvents(.stop()) {
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

        expectNoEvents(during: .seconds(2)) {
            player.play()
        }

        expectAtLeastEvents(.play()) {
            player.isTrackingEnabled = true
        }
    }
}
