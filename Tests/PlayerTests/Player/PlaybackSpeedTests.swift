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
    func testOnDemandPlaybackSpeed() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        expectAtLeastEqualPublished(values: [0, 2], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(2)
        }
    }

    func testLivePlaybackSpeedZeroForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expectAtLeastEqualPublished(values: [1], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(0)
        }
    }

    func testLivePlaybackSpeedGreaterThanZeroForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        expectAtLeastEqualPublished(values: [1], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(2)
        }
    }

    func testDvrPlaybackSpeedAtLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        expectAtLeastEqualPublished(values: [0, 1], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(2)
        }
    }

    func testDvrPlaybackSpeedLessThanOneAtLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        expectAtLeastEqualPublished(values: [0, 0.5], from: player.$playbackSpeed) {
            player.setPlaybackSpeed(0.5)
        }
    }

    func testDvrPlaybackSpeedNotAtLiveEdge() {
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

    func testSyncBetweenPlaybackSpeedAndRate() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.setPlaybackSpeed(2)
        player.pause()
        expect(player.playbackSpeed).toEventually(equal(player.queuePlayer.rate), pollInterval: .seconds(1))
    }
}
