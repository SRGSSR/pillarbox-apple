//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import Nimble
import XCTest

final class ItemInsertionAfterTests: XCTestCase {
    func testInsertItemAfterNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
    }

    func testInsertItemAfterCurrentItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
    }

    func testInsertItemAfterPreviousItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
    }

    func testInsertItemAfterLastItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem]))
    }

    func testInsertItemAfterIdenticalItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.insert(item1, after: item2)).to(beFalse())
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testInsertItemAfterForeignItem() {
        let item = PlayerItem(url: Stream.item.url)
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        let foreignItem = PlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.insert(insertedItem, after: foreignItem)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testInsertItemAfterNil() {
        let item = PlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: nil)).to(beTrue())
        expect(player.items).to(equalDiff([item, insertedItem]))
    }

    func testAppendItem() {
        let item = PlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem(url: Stream.insertedItem.url)
        expect(player.append(insertedItem)).to(beTrue())
        expect(player.items).to(equalDiff([item, insertedItem]))
    }
}
