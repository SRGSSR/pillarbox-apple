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
final class ItemMoveAfterTests: XCTestCase {
    func testMovePreviousItemAfterNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.move(item1, after: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item3, item1]))
    }

    func testMovePreviousItemAfterCurrentItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.move(item1, after: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item3, item1]))
    }

    func testMovePreviousItemAfterPreviousItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.move(item1, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1, item3]))
    }

    func testMoveCurrentItemAfterNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.move(item1, after: item2)).to(beTrue())
        expect(player.currentItem).to(equal(item1))
        expect(player.items).to(equalDiff([item2, item1, item3]))
    }

    func testMoveCurrentItemAfterPreviousItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.move(item3, after: item1)).to(beTrue())
        expect(player.currentItem).to(equal(item3))
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    func testMoveNextItemAfterPreviousItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.move(item3, after: item1)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    func testMoveNextItemAfterCurrentItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.move(item3, after: item1)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    func testMoveNextItemAfterNextItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.move(item2, after: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    func testMoveItemAfterIdenticalItem() {
        let item = PlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        expect(player.move(item, after: item)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveItemAfterItemAlreadyAtExpectedLocation() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.move(item2, after: item1)).to(beFalse())
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testMoveForeignItemAfterItem() {
        let item = PlayerItem(url: Stream.item.url)
        let foreignItem = PlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.move(foreignItem, after: item)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveItemAfterForeignItem() {
        let item = PlayerItem(url: Stream.item.url)
        let foreignItem = PlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.move(item, after: foreignItem)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveItemAfterLastItem() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.move(item1, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1]))
    }

    func testMoveItemAfterNil() {
        let item1 = PlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.move(item1, after: nil)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1]))
    }

    func testMoveLastItemAfterNil() {
        let item = PlayerItem(url: Stream.item(numbered: 1).url)
        let player = Player(items: [item])
        expect(player.move(item, after: nil)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }
}
