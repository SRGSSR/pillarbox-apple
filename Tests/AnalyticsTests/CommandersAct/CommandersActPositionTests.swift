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

final class CommandersActPositionTests: CommandersActTestCase {
    func testLivePlayback() {
        let player = Player(item: .simple(
            url: Stream.live.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        XCTWaiter().wait(for: [XCTestExpectation()], timeout: 2)

        expectAtLeastEvents(
            .pause { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player.pause()
        }
    }

    func testDvrPlayback() {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        XCTWaiter().wait(for: [XCTestExpectation()], timeout: 2)

        expectAtLeastEvents(
            .pause { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player.pause()
        }
    }

    func testSeekDuringDvrPlayback() {
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
                expect(labels.media_position).to(equal(0))
            },
            .play { labels in
                expect(labels.media_position).to(equal(0))
            }
        ) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }
    }

    func testDestroyDuringLivePlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.live.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player?.play()
        expect(player?.playbackState).toEventually(equal(.playing))

        XCTWaiter().wait(for: [XCTestExpectation()], timeout: 2)

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player = nil
        }
    }

    func testDestroyDuringDvrPlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player?.play()
        expect(player?.playbackState).toEventually(equal(.playing))

        XCTWaiter().wait(for: [XCTestExpectation()], timeout: 2)

        expectAtLeastEvents(
            .stop { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player = nil
        }
    }
}
