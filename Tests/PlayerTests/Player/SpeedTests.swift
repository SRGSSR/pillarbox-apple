//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class SpeedTests: TestCase {
    @MainActor
    func testEmpty() async {
        let player = Player()
        await expect(player.playbackSpeed).toAlways(equal(1), until: .seconds(2))
        await expect(player.playbackSpeedRange).toAlways(equal(1...1), until: .seconds(2))
    }

    @MainActor
    func testNoSpeedUpdateWhenEmpty() async {
        let player = Player()
        player.playbackSpeed = 2
        await expect(player.playbackSpeed).toAlways(equal(1), until: .seconds(2))
        await expect(player.playbackSpeedRange).toAlways(equal(1...1), until: .seconds(2))
    }

    @MainActor
    func testOnDemand() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.playbackSpeed = 2
        await expect(player.playbackSpeed).toEventually(equal(2))
        await expect(player.playbackSpeedRange).toEventually(equal(0.1...2))
    }

    @MainActor
    func testDvr() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        player.playbackSpeed = 0.5
        await expect(player.playbackSpeed).toEventually(equal(0.5))
        await expect(player.playbackSpeedRange).toEventually(equal(0.1...1))
    }

    @MainActor
    func testLive() async {
        let player = Player(item: .simple(url: Stream.live.url))
        player.playbackSpeed = 2
        await expect(player.playbackSpeed).toAlways(equal(1), until: .seconds(2))
        await expect(player.playbackSpeedRange).toAlways(equal(1...1), until: .seconds(2))
    }

    @MainActor
    func testDvrInThePast() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        await expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        await waitUntil { done in
            player.seek(at(.init(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        await expect(player.playbackSpeedRange).toEventually(equal(0.1...2))
        player.playbackSpeed = 2
        await expect(player.playbackSpeed).toEventually(equal(2))
    }

    @MainActor
    func testPlaylistOnDemandToLive() async {
        let item1 = PlayerItem(asset: .simple(url: Stream.onDemand.url))
        let item2 = PlayerItem(asset: .simple(url: Stream.live.url))
        let player = Player(items: [item1, item2])

        player.playbackSpeed = 2
        await expect(player.playbackSpeed).toEventually(equal(2))

        player.advanceToNextItem()
        await expect(player.playbackSpeed).toEventually(equal(1))
        await expect(player.playbackSpeedRange).toEventually(equal(1...1))
    }

    @MainActor
    func testPlaylistOnDemandToOnDemand() async {
        let item1 = PlayerItem(asset: .simple(url: Stream.onDemand.url))
        let item2 = PlayerItem(asset: .simple(url: Stream.onDemand.url))
        let player = Player(items: [item1, item2])
        player.playbackSpeed = 2
        await expect(player.playbackSpeed).toEventually(equal(2))

        player.advanceToNextItem()
        await expect(player.playbackSpeed).toEventually(equal(2))
        await expect(player.playbackSpeedRange).toEventually(equal(0.1...2))
    }

    func testSpeedUpdateWhenStartingPlayback() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expectAtLeastEqualPublished(
            values: [1, 0.5],
            from: player.changePublisher(at: \.playbackSpeed).removeDuplicates()
        ) {
            player.playbackSpeed = 0.5
        }
    }

    func testSpeedRangeUpdateWhenStartingPlayback() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expectAtLeastEqualPublished(
            values: [1...1, 0.1...1],
            from: player.changePublisher(at: \.playbackSpeedRange).removeDuplicates()
        ) {
            player.playbackSpeed = 0.5
        }
    }

    @MainActor
    func testSpeedUpdateWhenApproachingLiveEdge() async {
        let player = Player(item: .simple(url: Stream.dvr.url))
        player.play()
        await expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        await waitUntil { done in
            player.seek(at(.init(value: 10, timescale: 1))) { _ in
                done()
            }
        }

        player.playbackSpeed = 2
        await expect(player.playbackSpeed).toEventually(equal(2))
        await expect(player.playbackSpeedRange).toEventually(equal(0.1...2))

        await expect(player.playbackSpeed).toEventually(equal(1))
        await expect(player.playbackSpeedRange).toEventually(equal(0.1...1))
    }

    @MainActor
    func testPlaylistEnd() async {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.playbackSpeed = 2
        player.play()
        await expect(player.currentItem).toEventually(beNil())

        await expect(player.playbackSpeed).toEventually(equal(1))
        await expect(player.playbackSpeedRange).toEventually(equal(1...1))
    }

    @MainActor
    func testItemAppendMustStartAtCurrentSpeed() async {
        let player = Player()
        player.playbackSpeed = 2
        player.append(.simple(url: Stream.onDemand.url))
        await expect(player.playbackSpeed).toEventually(equal(2))
    }

    @MainActor
    func testInitialSpeedMustSetRate() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.playbackSpeed = 2
        player.play()
        await expect(player.queuePlayer.defaultRate).toEventually(equal(2))
        await expect(player.queuePlayer.rate).toEventually(equal(2))
    }

    @MainActor
    func testSpeedUpdateMustUpdateRate() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))

        player.playbackSpeed = 2
        await expect(player.queuePlayer.defaultRate).toEventually(equal(2))
        await expect(player.queuePlayer.rate).toEventually(equal(2))
    }

    @MainActor
    func testSpeedUpdateWhilePausedMustUpdateRate() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.playbackState).toEventually(equal(.paused))

        player.playbackSpeed = 2
        player.play()

        await expect(player.queuePlayer.defaultRate).toEventually(equal(2))
        await expect(player.queuePlayer.rate).toEventually(equal(2))
    }

    @MainActor
    func testSpeedUpdateMustNotResumePlayback() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.playbackState).toEventually(equal(.paused))
        player.playbackSpeed = 2
        await expect(player.playbackState).toAlways(equal(.paused), until: .seconds(2))
    }

    @MainActor
    func testPlayMustNotResetSpeed() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.playbackSpeed = 2
        player.play()
        await expect(player.playbackSpeed).toEventually(equal(2))
    }

    @MainActor
    func testRateChangeMustNotUpdatePlaybackSpeedOutsideAVPlayerViewController() async {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        await expect(player.streamType).toEventually(equal(.onDemand))
        player.queuePlayer.rate = 2
        await expect(player.playbackSpeed).toAlways(equal(1), until: .seconds(2))
    }

    func testNoDesiredUpdateIsIgnored() {
        let player = Player()
        expectAtLeastEqualPublished(values: [
            .value(1),
            .value(2),
            .value(2)
        ], from: player.desiredPlaybackSpeedUpdatePublisher()) {
            player.playbackSpeed = 1
            player.playbackSpeed = 2
            player.playbackSpeed = 2
        }
    }
}
