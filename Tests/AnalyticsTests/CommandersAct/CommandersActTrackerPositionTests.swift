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

final class CommandersActTrackerPositionTests: CommandersActTestCase {
    @MainActor
    func testLivePlayback() async {
        let player = Player(item: .simple(
            url: Stream.live.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))
        wait(for: .seconds(2))

        expectAtLeastHits(
            pause { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player.pause()
        }
    }

    @MainActor
    func testDvrPlayback() async {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))
        wait(for: .seconds(2))

        expectAtLeastHits(
            pause { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player.pause()
        }
    }

    @MainActor
    func testSeekDuringDvrPlayback() async {
        let player = Player(item: .simple(
            url: Stream.dvr.url,
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
                expect(labels.media_position).to(equal(0))
            }
        ) {
            player.seek(at(.init(value: 7, timescale: 1)))
        }
    }

    @MainActor
    func testDestroyDuringLivePlayback() async {
        var player: Player? = Player(item: .simple(
            url: Stream.live.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player?.play()
        await expect(player?.playbackState).toEventually(equal(.playing))
        wait(for: .seconds(2))

        expectAtLeastHits(
            stop { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player = nil
        }
    }

    @MainActor
    func testDestroyDuringDvrPlayback() async {
        var player: Player? = Player(item: .simple(
            url: Stream.dvr.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ]
        ))

        player?.play()
        await expect(player?.playbackState).toEventually(equal(.playing))
        wait(for: .seconds(2))

        expectAtLeastHits(
            stop { labels in
                expect(labels.media_position).to(equal(2))
            }
        ) {
            player = nil
        }
    }

    func testOnDemandStartAtGivenPosition() {
        let player = Player(item: .simple(
            url: Stream.onDemand.url,
            trackerAdapters: [
                CommandersActTracker.adapter { _ in .test }
            ],
            configuration: .init(position: at(.init(value: 100, timescale: 1)))
        ))
        expectAtLeastHits(
            play { labels in
                expect(labels.media_position).to(equal(100))
            }
        ) {
            player.play()
        }
    }
}
