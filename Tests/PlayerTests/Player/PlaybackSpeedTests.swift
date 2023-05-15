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
}
