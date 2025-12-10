//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxAnalytics

import Nimble
import PillarboxPlayer
import PillarboxStreams

final class CommandersActTrackerSeekTests: CommandersActTestCase {
    @MainActor
    func testSeekWhilePlaying() async {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            seek { labels in
                expect(labels.media_position).to(equal(0))
            },
            play { labels in
                expect(labels.media_position).to(equal(7))
            }
        ) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }
    }

    @MainActor
    func testSeekWhilePaused() async {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        await expect(player.playbackState).toEventually(equal(.paused))

        expectNoHits(during: .milliseconds(500)) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }

        expectAtLeastHits(
            play { labels in
                expect(labels.media_position).to(equal(7))
            }
        ) {
            player.play()
        }
    }

    @MainActor
    func testDestroyPlayerWhileSeeking() async {
        var player: Player? = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player?.play()
        await expect(player?.playbackState).toEventually(equal(.playing))

        expectAtLeastHits(
            seek { labels in
                expect(labels.media_position).to(equal(0))
            },
            stop { labels in
                expect(labels.media_position).to(equal(7))
            }
        ) {
            player?.seek(at(.init(value: 7, timescale: 1)))
            player = nil
        }
    }
}
