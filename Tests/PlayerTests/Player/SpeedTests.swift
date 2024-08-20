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
    func testEmpty() {
        let player = Player()
        expect(player.effectivePlaybackSpeed).toAlways(equal(1), until: .seconds(2))
        expect(player.playbackSpeedRange).toAlways(equal(1...1), until: .seconds(2))
    }

    func testNoSpeedUpdateWhenEmpty() {
        let player = Player()
        player.setDesiredPlaybackSpeed(2)
        expect(player.effectivePlaybackSpeed).toAlways(equal(1), until: .seconds(2))
        expect(player.playbackSpeedRange).toAlways(equal(1...1), until: .seconds(2))
    }

    func testOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.setDesiredPlaybackSpeed(2)
        expect(player.effectivePlaybackSpeed).toEventually(equal(2))
        expect(player.playbackSpeedRange).toEventually(equal(0.1...2))
    }

    func testDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        player.setDesiredPlaybackSpeed(0.5)
        expect(player.effectivePlaybackSpeed).toEventually(equal(0.5))
        expect(player.playbackSpeedRange).toEventually(equal(0.1...1))
    }

    func testLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        player.setDesiredPlaybackSpeed(2)
        expect(player.effectivePlaybackSpeed).toAlways(equal(1), until: .seconds(2))
        expect(player.playbackSpeedRange).toAlways(equal(1...1), until: .seconds(2))
    }

    func testDvrInThePast() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        waitUntil { done in
            player.seek(at(.init(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        expect(player.playbackSpeedRange).toEventually(equal(0.1...2))
        player.setDesiredPlaybackSpeed(2)
        expect(player.effectivePlaybackSpeed).toEventually(equal(2))
    }

    func testPlaylistOnDemandToLive() {
        let item1 = PlayerItem(asset: .simple(url: Stream.onDemand.url))
        let item2 = PlayerItem(asset: .simple(url: Stream.live.url))
        let player = Player(items: [item1, item2])

        player.setDesiredPlaybackSpeed(2)
        expect(player.effectivePlaybackSpeed).toEventually(equal(2))

        player.advanceToNextItem()
        expect(player.effectivePlaybackSpeed).toEventually(equal(1))
        expect(player.playbackSpeedRange).toEventually(equal(1...1))
    }

    func testPlaylistOnDemandToOnDemand() {
        let item1 = PlayerItem(asset: .simple(url: Stream.onDemand.url))
        let item2 = PlayerItem(asset: .simple(url: Stream.onDemand.url))
        let player = Player(items: [item1, item2])
        player.setDesiredPlaybackSpeed(2)
        expect(player.effectivePlaybackSpeed).toEventually(equal(2))

        player.advanceToNextItem()
        expect(player.effectivePlaybackSpeed).toEventually(equal(2))
        expect(player.playbackSpeedRange).toEventually(equal(0.1...2))
    }

    func testSpeedUpdateWhenStartingPlayback() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expectEqualPublished(
            values: [1, 0.5],
            from: player.changePublisher(at: \.effectivePlaybackSpeed).removeDuplicates(),
            during: .seconds(2)
        ) {
            player.setDesiredPlaybackSpeed(0.5)
        }
    }

    func testSpeedRangeUpdateWhenStartingPlayback() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expectEqualPublished(
            values: [1...1, 0.1...1],
            from: player.changePublisher(at: \.playbackSpeedRange).removeDuplicates(),
            during: .seconds(2)
        ) {
            player.setDesiredPlaybackSpeed(0.5)
        }
    }

    func testSpeedUpdateWhenApproachingLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        player.play()
        expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        waitUntil { done in
            player.seek(at(.init(value: 10, timescale: 1))) { _ in
                done()
            }
        }

        player.setDesiredPlaybackSpeed(2)
        expect(player.effectivePlaybackSpeed).toEventually(equal(2))
        expect(player.playbackSpeedRange).toEventually(equal(0.1...2))

        expect(player.effectivePlaybackSpeed).toEventually(equal(1))
        expect(player.playbackSpeedRange).toEventually(equal(0.1...1))
    }

    func testPlaylistEnd() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.setDesiredPlaybackSpeed(2)
        player.play()
        expect(player.currentItem).toEventually(beNil())

        expect(player.effectivePlaybackSpeed).toEventually(equal(1))
        expect(player.playbackSpeedRange).toEventually(equal(1...1))
    }

    func testItemAppendMustStartAtCurrentSpeed() {
        let player = Player()
        player.setDesiredPlaybackSpeed(2)
        player.append(.simple(url: Stream.onDemand.url))
        expect(player.effectivePlaybackSpeed).toEventually(equal(2))
    }

    func testInitialSpeedMustSetRate() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.setDesiredPlaybackSpeed(2)
        player.play()
        expect(player.queuePlayer.defaultRate).toEventually(equal(2))
        expect(player.queuePlayer.rate).toEventually(equal(2))
    }

    func testSpeedUpdateMustUpdateRate() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        player.setDesiredPlaybackSpeed(2)
        expect(player.queuePlayer.defaultRate).toEventually(equal(2))
        expect(player.queuePlayer.rate).toEventually(equal(2))
    }

    func testSpeedUpdateWhilePausedMustUpdateRate() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.playbackState).toEventually(equal(.paused))

        player.setDesiredPlaybackSpeed(2)
        player.play()

        expect(player.queuePlayer.defaultRate).toEventually(equal(2))
        expect(player.queuePlayer.rate).toEventually(equal(2))
    }

    func testSpeedUpdateMustNotResumePlayback() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.playbackState).toEventually(equal(.paused))
        player.setDesiredPlaybackSpeed(2)
        expect(player.playbackState).toAlways(equal(.paused), until: .seconds(2))
    }

    func testPlayMustNotResetSpeed() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.setDesiredPlaybackSpeed(2)
        player.play()
        expect(player.effectivePlaybackSpeed).toEventually(equal(2))
    }

    func testRateChangeMustNotUpdatePlaybackSpeedOutsideAVPlayerViewController() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.queuePlayer.rate = 2
        expect(player.effectivePlaybackSpeed).toAlways(equal(1), until: .seconds(2))
    }

    func testNoDesiredUpdateIsIgnored() {
        let player = Player()
        expectAtLeastEqualPublished(values: [
            .value(1),
            .value(2),
            .value(2)
        ], from: player.desiredPlaybackSpeedUpdatePublisher()) {
            player.setDesiredPlaybackSpeed(1)
            player.setDesiredPlaybackSpeed(2)
            player.setDesiredPlaybackSpeed(2)
        }
    }
}
