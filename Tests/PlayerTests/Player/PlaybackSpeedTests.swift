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
            player.playbackSpeed = 2
        }
    }

    func testLivePlaybackSpeedZeroForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        player.play()
        player.playbackSpeed = 0
        expectAtLeastEqualPublished(values: [1], from: player.$playbackSpeed)
    }

    func testLivePlaybackSpeedGreaterThanZeroForLive() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.streamType).toEventually(equal(.live))
        player.playbackSpeed = 2
        expectAtLeastEqualPublished(values: [1], from: player.$playbackSpeed)
    }

    func testDvrPlaybackSpeedAtLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        player.play()
        player.playbackSpeed = 2
        expectAtLeastEqualPublished(values: [1], from: player.$playbackSpeed)
    }

    func testDvrPlaybackSpeedNotAtLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        player.seek(at(.init(value: 7, timescale: 1)))
        expect(player.streamType).toEventually(equal(.dvr))
        expectAtLeastEqualPublished(values: [1, 2], from: player.$playbackSpeed) {
            player.playbackSpeed = 2
        }
    }

    func testDvrPlaybackSpeedNotAtLiveEdgeToLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        player.seek(at(.init(value: 15, timescale: 1)))
        expect(player.streamType).toEventually(equal(.dvr))
        expectAtLeastEqualPublished(values: [1, 2], from: player.$playbackSpeed) {
            player.playbackSpeed = 2
        }
    }

    func testPlaylistOnDemandToLive() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        player.play()
        player.playbackSpeed = 2
        expect(player.streamType).toEventually(equal(.onDemand))
        expectAtLeastEqualPublished(values: [1], from: player.$playbackSpeed) {
            player.advanceToNext()
        }
    }

    func testPlaylistOnDemandToDemand() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.onDemand))
        player.playbackSpeed = 2
        expectAtLeastEqualPublished(values: [2], from: player.$playbackSpeed) {
            player.advanceToNext()
        }
    }

    func testAvoidingToSetTheSamePlaybackSpeed() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.playbackSpeed = 1
        expectEqualPublished(values: [1], from: player.$playbackSpeed, during: .seconds(2))
    }

    func testSyncBetweenPlaybackSpeedAndRate() {
        let player = Player(item: .simple(url: Stream.onDemand.url))
        expect(player.streamType).toEventually(equal(.onDemand))
        player.playbackSpeed = 2
        player.pause()
        expect(player.playbackSpeed).toEventually(equal(player.queuePlayer.rate), pollInterval: .seconds(1))
    }
}
