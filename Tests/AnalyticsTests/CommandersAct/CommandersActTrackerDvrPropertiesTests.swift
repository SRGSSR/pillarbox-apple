//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import CoreMedia
import Nimble
import Player
import Streams
import XCTest

final class CommandersActTrackerDvrPropertiesTests: CommandersActTestCase {
    func testOnDemand() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_timeshift).to(beNil())
            }
        ) {
            player.play()
        }
    }

    func testLive() {
        let player = Player(item: .simple(
            url: Stream.live.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            player.play()
        }
    }

    func testDvrAtLiveEdge() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_timeshift).to(equal(0))
            }
        ) {
            player.play()
        }
    }

    func testDvrAwayFromLiveEdge() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastEvents(
            .seek { labels in
                expect(labels.media_timeshift).to(equal(0))
            },
            .play { labels in
                expect(labels.media_timeshift).to(equal(4))
            }
        ) {
            player.seek(at(player.timeRange.end - CMTime(value: 4, timescale: 1)))
        }
    }

    func testDestroyPlayerDuringPlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player?.play()
        expect(player?.playbackState).toEventually(equal(.playing))

        player?.pause()
        XCTWaiter().wait(for: [XCTestExpectation()], timeout: 2)

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_timeshift).to(equal(2))
            }
        ) {
            player = nil
        }
    }

    func testDestroyPlayerWhileInitiallyPaused() {
        var player: Player? = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))
        expect(player?.playbackState).toEventually(equal(.paused))

        expectNoEvents(during: .seconds(5)) {
            player = nil
        }
    }
}
