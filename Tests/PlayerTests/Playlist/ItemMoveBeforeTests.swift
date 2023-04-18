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

final class ItemMoveBeforeTests: TestCase {
    func testMovePreviousItemBeforeNextItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.move(item1, before: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1, item3]))
    }

    func testMovePreviousItemBeforeCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.move(item1, before: item3)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1, item3]))
    }

    func testMovePreviousItemBeforePreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.move(item2, before: item1)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1, item3]))
    }

    func testMoveCurrentItemBeforeNextItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.move(item1, before: item3)).to(beTrue())
        expect(player.currentIndex).to(equal(1))
        expect(player.items).to(equalDiff([item2, item1, item3]))
    }

    func testMoveCurrentItemBeforePreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.move(item2, before: item1)).to(beTrue())
        expect(player.currentIndex).to(equal(0))
        expect(player.items).to(equalDiff([item2, item1, item3]))
    }

    func testMoveNextItemBeforePreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.move(item3, before: item1)).to(beTrue())
        expect(player.items).to(equalDiff([item3, item1, item2]))
    }

    func testMoveNextItemBeforeCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.move(item3, before: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    func testMoveNextItemBeforeNextItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let item3 = PlayerItem.simple(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.move(item3, before: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item3, item2]))
    }

    func testMoveItemBeforeIdenticalItem() {
        let item = PlayerItem.simple(url: Stream.item.url)
        let player = Player(items: [item])
        expect(player.move(item, before: item)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveItemBeforeItemAlreadyAtExpectedLocation() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.move(item1, before: item2)).to(beFalse())
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testMoveForeignItemBeforeItem() {
        let item = PlayerItem.simple(url: Stream.item.url)
        let foreignItem = PlayerItem.simple(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.move(foreignItem, before: item)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveBeforeForeignItem() {
        let item = PlayerItem.simple(url: Stream.item.url)
        let foreignItem = PlayerItem.simple(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.move(item, before: foreignItem)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testMoveItemBeforeFirstItem() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.move(item2, before: item1)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1]))
    }

    func testMoveBeforeNil() {
        let item1 = PlayerItem.simple(url: Stream.item(numbered: 1).url)
        let item2 = PlayerItem.simple(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.move(item2, before: nil)).to(beTrue())
        expect(player.items).to(equalDiff([item2, item1]))
    }

    func testMoveFirstItemBeforeNil() {
        let item = PlayerItem.simple(url: Stream.item.url)
        let player = Player(items: [item])
        expect(player.move(item, before: nil)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }
}
