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

final class CommandersActTrackerSeekTests: CommandersActTestCase {
    func testSeekWhilePlaying() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
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
                expect(labels.media_position).to(equal(7))
            }
        ) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }
    }

    func testSeekWhilePaused() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        expect(player.playbackState).toEventually(equal(.paused))

        expectNoEvents(during: .seconds(2)) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }

        expectAtLeastEvents(
            .play { labels in
                expect(labels.media_position).to(equal(7))
            }
        ) {
            player.play()
        }
    }

    func testDestroyPlayerWhileSeeking() {
        var player: Player? = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter()
            ]
        ))

        player?.play()
        expect(player?.playbackState).toEventually(equal(.playing))

        expectAtLeastEvents(
            .seek { labels in
                expect(labels.media_position).to(equal(0))
            },
            .stop { labels in
                expect(labels.media_position).to(equal(0))
            }
        ) {
            player?.seek(at(.init(value: 7, timescale: 1)))
            player = nil
        }
    }
}
