//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import CoreMedia
import Nimble
import XCTest

final class PlayerTests: TestCase {
    func testConstants() {
        expect(Player.startTimeThreshold).to(equal(3))
    }

    func testDeallocation() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        var player: Player? = Player(item: item)

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }

    func testTimesWhenEmpty() {
        let player = Player()
        expect(player.time).toAlways(equal(.invalid), until: .seconds(1))
    }

    func testTimesInEmptyRange() {
        let player = Player(item: .simple(url: Stream.live.url))
        expect(player.timeRange).toEventuallyNot(equal(.invalid))
        player.play()
        expect(player.time).toNever(equal(.invalid), until: .seconds(1))
    }

    func testTimesStayInRange() {
        let player = Player(item: .simple(url: Stream.dvr.url))
        expect(player.timeRange).toEventuallyNot(equal(.invalid))
        player.play()
        expect {
            player.timeRange.start <= player.time && player.time <= player.timeRange.end
        }
        .toAlways(beTrue(), until: .seconds(1))
    }

    func testMetadataUpdatesMustNotChangePlayerItem() {
        let player = Player(item: .mock(url: Stream.onDemand.url, withMetadataUpdateAfter: 1))
        expectNothingPublishedNext(from: player.queuePlayer.publisher(for: \.currentItem), during: .seconds(2))
    }
}
