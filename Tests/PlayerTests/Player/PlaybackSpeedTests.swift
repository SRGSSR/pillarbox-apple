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

final class PlaybackSpeedTests: TestCase {
    func testOnDemand() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expectAtLeastEqualPublished(values: [0, 2], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(2)
        }
    }

    func testZeroForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expectAtLeastEqualPublished(values: [1], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(0)
        }
    }

    func testGreaterThanOneForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expectAtLeastEqualPublished(values: [1], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(2)
        }
    }

    func testDvrAtLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        expectAtLeastEqualPublished(values: [0, 1], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(2)
        }
    }

    func testDvrLessThanOneAtLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        expectAtLeastEqualPublished(values: [0, 0.5], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(0.5)
        }
    }

    func testDvrGreaterThanOneNotAtLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))

        waitUntil { done in
            player.seek(at(.init(value: 1, timescale: 1))) { _ in
                done()
            }
        }

        expectAtLeastEqualPublished(values: [0, 2], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(2)
        }
    }

    func testPlaylistOnDemandToLive() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.onDemand))
        expectAtLeastEqualPublished(values: [0, 2, 1], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(2)
            player.advanceToNext()
        }
    }

    func testPlaylistHighSpeedShouldNotMoveToNext() {
        let item1 = PlayerItem.simple(url: Stream.dvr.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.dvr))
        waitUntil { done in
            player.seek(at(.init(value: 1, timescale: 1))) { _ in
                done()
            }
        }
        player.setPlaybackSpeed(2)
        expectEqualPublished(values: [2, 1], from: player.$playbackSpeed, during: .seconds(3)) {
            player.skipToDefault()
        }
        expect(player.streamType).toEventually(equal(.dvr))
    }

    func testPlaylistOnDemandToDemand() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.onDemand))
        expectAtLeastEqualPublished(values: [0, 2], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(2)
            player.advanceToNext()
        }
    }

    func testSyncBetweenSpeedAndRate() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.setPlaybackSpeed(2)
        player.pause()
        expect(player.playbackSpeed).toEventually(equal(player.queuePlayer.rate), pollInterval: .seconds(1))
    }
}
