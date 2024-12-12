//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import CoreMedia
import Nimble
import PillarboxCircumspect
import PillarboxPlayer
import PillarboxStreams

final class CommandersActTrackerDvrPropertiesTests: CommandersActTestCase {
    func testOnDemand() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            play { labels in
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
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            play { labels in
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
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        expectAtLeastHits(
            play { labels in
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
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            seek { labels in
                expect(labels.media_timeshift).to(equal(0))
            },
            play { labels in
                expect(labels.media_timeshift).to(beCloseTo(4, within: 2))
            }
        ) {
            player.seek(at(player.time() - CMTime(value: 4, timescale: 1)))
        }
    }

    func testDestroyPlayerDuringPlayback() {
        var player: Player? = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))
        expectAtLeastHits(play()) {
            player?.play()
        }
        expectAtLeastHits(
            stop { labels in
                expect(labels.media_position).notTo(beNil())
            }
        ) {
            player = nil
        }
    }

    func testDestroyPlayerWhileInitiallyPaused() {
        var player: Player? = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))
        expect(player?.playbackState).toEventually(equal(.paused))

        expectNoHits(during: .milliseconds(500)) {
            player = nil
        }
    }
}
