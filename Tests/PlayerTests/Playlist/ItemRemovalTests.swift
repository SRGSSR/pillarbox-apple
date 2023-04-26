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

final class ItemRemovalTests: TestCase {
    func testRemovePreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.remove(item1)
        expect(player.items).to(equalDiff([item2, item3]))
    }

    func testRemoveCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.remove(item2)
        expect(player.currentIndex).to(equal(1))
        expect(player.items).to(equalDiff([item1, item3]))
    }

    func testRemoveNextItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.remove(item3)
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testRemoveForeignItem() {
        let item = PlayerItem.simple(url: Stream.item.url)
        let foreignItem = PlayerItem.simple(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        player.remove(foreignItem)
        expect(player.items).to(equalDiff([item]))
    }

    func testRemoveAllItems() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.removeAllItems()
        expect(player.items).to(beEmpty())
        expect(player.currentIndex).to(beNil())
    }
}
