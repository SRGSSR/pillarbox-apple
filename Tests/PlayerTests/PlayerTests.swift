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

@MainActor
final class PlayerTests: XCTestCase {
    func testCurrentItem() {
        let item1 = PlayerItem(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [item1, item2],
            from: player.$currentItem
        ) {
            player.play()
        }
    }

    func testSlowFirstCurrentItem() {
        let item1 = PlayerItem(url: Stream.shortOnDemand.url, delay: 2)
        let item2 = PlayerItem(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [item1, item2],
            from: player.$currentItem
        ) {
            player.play()
        }
    }

    func testChunkDuration() {
        let item = PlayerItem(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expectEqualPublished(
            values: [.invalid, CMTime(value: 1, timescale: 1)],
            from: player.$chunkDuration,
            during: 3
        )
    }

    func testChunkDurationDuringEntirePlayback() {
        let item = PlayerItem(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [.invalid, CMTime(value: 1, timescale: 1), .invalid],
            from: player.$chunkDuration
        ) {
            player.play()
        }
    }

    func testCheckDurationsDuringItemChange() {
        let item1 = PlayerItem(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectEqualPublished(
            values: [
                .invalid,
                CMTime(value: 1, timescale: 1),
                .invalid,
                CMTime(value: 4, timescale: 1)
            ],
            from: player.$chunkDuration,
            during: 3
        ) {
            player.play()
        }
    }

    func testDeallocation() {
        let item = PlayerItem(url: Stream.onDemand.url)
        var player: Player? = Player(item: item)

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }
}
