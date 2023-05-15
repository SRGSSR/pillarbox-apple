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
        player.playbackSpeed = 2
        expectAtLeastEqualPublished(values: [2], from: player.$playbackSpeed)
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
        player.play()
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
        expect(player.streamType).toEventually(equal(.dvr))
        player.play()
        player.seek(at(.init(value: 7, timescale: 1)))
        player.playbackSpeed = 2
        expectAtLeastEqualPublished(values: [2], from: player.$playbackSpeed)
    }

    func testDvrPlaybackSpeedNotAtLiveEdgeToLiveEdge() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.streamType).toEventually(equal(.dvr))
        player.seek(at(.init(value: 15, timescale: 1)))
        player.playbackSpeed = 2
        expectEqualPublished(values: [2, 1], from: player.$playbackSpeed.removeDuplicates(), during: .seconds(3)) {
            player.play()
        }
    }

    func testPlaylistOnDemandToLive() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.live.url)
        let player = Player(items: [item1, item2])
        player.play()
        player.playbackSpeed = 2
        expect(player.streamType).toEventually(equal(.onDemand))
        expectEqualPublished(values: [2, 1], from: player.$playbackSpeed.removeDuplicates(), during: .seconds(3)) {
            player.advanceToNext()
        }
    }

    func testPlaylistOnDemandToDemand() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.streamType).toEventually(equal(.onDemand))
        player.play()
        player.playbackSpeed = 2
        expectEqualPublished(values: [2], from: player.$playbackSpeed.removeDuplicates(), during: .seconds(3)) {
            player.advanceToNext()
        }
    }
}
