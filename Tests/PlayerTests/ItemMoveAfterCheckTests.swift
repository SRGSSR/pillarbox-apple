//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

@MainActor
final class ItemMoveAfterCheckTests: XCTestCase {
    func testCanMovePreviousItemAfterNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item1, after: item3)).to(beTrue())
    }

    func testCanMovePreviousItemAfterCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item1, after: item2)).to(beTrue())
    }

    func testCanMovePreviousItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))
        expect(player.canMove(item1, after: item2)).to(beTrue())
    }

    func testCanMoveCurrentItemAfterNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item1, after: item2)).to(beTrue())
    }

    func testCanMoveCurrentItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))
        expect(player.canMove(item3, after: item1)).to(beTrue())
    }

    func testCanMoveNextItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item3, after: item1)).to(beTrue())
    }

    func testCanMoveNextItemAfterCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item3, after: item1)).to(beTrue())
    }

    func testCanMoveNextItemAfterNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item2, after: item3)).to(beTrue())
    }

    func testCannotMoveAfterIdenticalItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        expect(player.canMove(item, after: item)).to(beFalse())
    }

    func testCannotMoveAfterItemIfAlreadyAtExpectedLocation() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canMove(item2, after: item1)).to(beFalse())
    }

    func testCannotMoveForeignItemAfterItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let foreignItem = AVPlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.canMove(foreignItem, after: item)).to(beFalse())
    }

    func testCannotMoveItemAfterForeignItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let foreignItem = AVPlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.canMove(item, after: foreignItem)).to(beFalse())
    }

    func testCanMoveAfterLastItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canMove(item1, after: item2)).to(beTrue())
    }

    func testCanMoveItemAfterNil() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canMove(item1, after: nil)).to(beTrue())
    }

    func testCannotMoveLastItemAfterNil() {
        let item = AVPlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        expect(player.canMove(item, after: nil)).to(beFalse())
    }
}
