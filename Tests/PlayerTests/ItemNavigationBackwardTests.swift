//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Nimble
import XCTest

final class ItemNavigationBackwardTests: TestCase {
    func testReturnToPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnToPreviousItemAtFront() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }

    func testReturnToPreviousItemOnFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.returnToPreviousItem()
        expect(player.currentIndex).to(equal(0))
    }
}
