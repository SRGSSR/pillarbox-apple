//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
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
            // `nil` initially not expected but is an artifact of `replaceCurrentItem(with:)`.
            values: [item1, nil, item2],
            from: player.$currentItem
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
