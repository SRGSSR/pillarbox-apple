//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import Streams
import XCTest

final class SpeedTests: TestCase {
    func testPlaybackSpeed() {
        let player = Player()
        expect(player.playbackSpeed).to(equal(1))
        expect(player.playbackSpeedRange).to(equal(1...1))
    }

    func testOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.playbackSpeed = 2
        expect(player.playbackSpeed).to(equal(2))
        expect(player.playbackSpeedRange).to(equal(0.1...2))
    }

    func testDvr() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        player.playbackSpeed = 0.5
        expect(player.playbackSpeed).to(equal(0.5))
        expect(player.playbackSpeedRange).to(equal(0.1...1))
    }

    func testLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        player.playbackSpeed = 2
        expect(player.playbackSpeed).to(equal(1))
        expect(player.playbackSpeedRange).to(equal(1...1))
    }

    func testDvrInThePast() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))

        waitUntil { done in
            player.seek(at(.init(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        expect(player.playbackSpeedRange).to(equal(0.1...2))
        player.playbackSpeed = 2
        expect(player.playbackSpeed).to(equal(2))
    }

    func testPlaylistOnDemandToLive() {
        let item1 = PlayerItem(asset: .simple(url: Stream.onDemand.url))
        let item2 = PlayerItem(asset: .simple(url: Stream.live.url))
        let player = Player(items: [item1, item2])

        player.playbackSpeed = 2
        expect(player.playbackSpeed).toEventually(equal(2))

        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.live))

        expect(player.playbackSpeed).to(equal(1))
        expect(player.playbackSpeedRange).to(equal(1...1))
    }

    func testPlaylistOnDemandToOnDemand() {
        let item1 = PlayerItem(asset: .simple(url: Stream.onDemand.url))
        let item2 = PlayerItem(asset: .simple(url: Stream.onDemand.url))
        let player = Player(items: [item1, item2])

        player.playbackSpeed = 2
        expect(player.playbackSpeed).toEventually(equal(2))

        player.advanceToNextItem()
        expect(player.streamType).toEventually(equal(.onDemand))

        expect(player.playbackSpeed).to(equal(2))
        expect(player.playbackSpeedRange).to(equal(0.1...2))
    }

    func testSpeedUpdateWhenStartingPlayback() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.playbackState).toEventually(equal(.paused))

        expectEqualPublished(
            values: [1, 0.5],
            from: player.changePublisher(at: \.playbackSpeed).removeDuplicates(),
            during: .seconds(2)
        ) {
            player.playbackSpeed = 0.5
        }
    }

    func testSpeedRangeUpdateWhenStartingPlayback() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.playbackState).toEventually(equal(.paused))

        expectEqualPublished(
            values: [1...1, 0.1...1],
            from: player.changePublisher(at: \.playbackSpeedRange).removeDuplicates(),
            during: .seconds(2)
        ) {
            player.playbackSpeed = 0.5
        }
    }

    func testSpeedUpdateWhenApproachingLiveEdge() {
    }
}
