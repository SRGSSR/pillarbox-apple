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
final class ItemRemovalTests: XCTestCase {
    func testRemovePreviousItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.remove(item1)
        expect(player.items).to(equalDiff([item2, item3]))
    }

    func testRemoveCurrentItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.remove(item2)
        expect(player.currentItem).to(equal(item3))
        expect(player.items).to(equalDiff([item1, item3]))
    }

    func testRemoveNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.remove(item3)
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testRemoveForeignItem() {
        let item = PlayerItem(url: Stream.item.url)
        let foreignItem = PlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        player.remove(foreignItem)
        expect(player.items).to(equalDiff([item]))
    }

    func testRemoveAllItems() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.removeAllItems()
        expect(player.items).to(beEmpty())
        expect(player.currentItem).to(beNil())
    }
}
