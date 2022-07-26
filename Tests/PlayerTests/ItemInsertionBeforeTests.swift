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
final class ItemInsertionBeforeTests: XCTestCase {
    func testInsertItemBeforeNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, before: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, insertedItem, item2, item3]))
    }

    func testInsertItemBeforeCurrentItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, before: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, insertedItem, item2, item3]))
    }

    func testInsertItemBeforePreviousItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, before: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, insertedItem, item2, item3]))
    }

    func testInsertItemBeforeFirstItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, before: item1)).to(beTrue())
        expect(player.items).to(equalDiff([insertedItem, item1, item2]))
    }

    func testInsertItemBeforeIdenticalItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.insert(item1, before: item2)).to(beFalse())
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testInsertItemBeforeForeignItem() {
        let item = PlayerItem(url: Stream.item.url)
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        let foreignItem = PlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.insert(insertedItem, before: foreignItem)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testInsertItemBeforeNil() {
        let item = PlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, before: nil)).to(beTrue())
        expect(player.items).to(equalDiff([insertedItem, item]))
    }

    func testPrependItem() {
        let item = PlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.prepend(insertedItem)).to(beTrue())
        expect(player.items).to(equalDiff([insertedItem, item]))
    }
}
