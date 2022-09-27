//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

@MainActor
final class DequePlayerTests: XCTestCase {
    func testEmpty() {
        let player = DequePlayer()
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(beEmpty())
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(beEmpty())
    }

    func testCanInsertBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, before: item2)).to(beTrue())
    }

    func testCanInsertBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, before: item2)).to(beTrue())
    }

    func testCanInsertBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, before: item2)).to(beTrue())
    }

    func testCanInsertBeforeFirstItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, before: item1)).to(beTrue())
    }

    func testCannotInsertBeforeIdenticalItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canInsert(item1, before: item2)).to(beFalse())
    }

    func testCannotInsertBeforeForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canInsert(insertedItem, before: foreignItem)).to(beFalse())
    }

    func testCanInsertBeforeNil() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canInsert(insertedItem, before: nil)).to(beTrue())
    }

    func testCanInsertAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, after: item2)).to(beTrue())
    }

    func testCanInsertAfterCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, after: item2)).to(beTrue())
    }

    func testCanInsertAfterPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, after: item2)).to(beTrue())
    }

    func testCanInsertAfterLastItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, after: item2)).to(beTrue())
    }

    func testCannotInsertAfterIdenticalItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canInsert(item1, after: item2)).to(beFalse())
    }

    func testCannotInsertAfterForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canInsert(insertedItem, after: foreignItem)).to(beFalse())
    }

    func testCanInsertAfterNil() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canInsert(insertedItem, after: nil)).to(beTrue())
    }

    func testInsertBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, before: item2)
        expect(player.items()).to(equalDiff([item1, insertedItem, item2]))
        expect(player.nextItems()).to(equalDiff([insertedItem, item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testInsertBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, before: item2)
        expect(player.items()).to(equalDiff([item1, insertedItem, item2, item3]))
        expect(player.nextItems()).to(equalDiff([item3]))
        expect(player.previousItems()).to(equalDiff([item1, insertedItem]))
    }

    func testInsertBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, before: item2)
        expect(player.items()).to(equalDiff([item1, insertedItem, item2, item3]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item1, insertedItem, item2]))
    }

    func testInsertBeforeFirstItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, before: item1)
        expect(player.items()).to(equalDiff([insertedItem, item1, item2]))
        expect(player.nextItems()).to(equalDiff([item2]))
        expect(player.previousItems()).to(equalDiff([insertedItem]))
    }

    func testInsertBeforeIdenticalItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        player.insert(item1, before: item2)
        expect(player.items()).to(equalDiff([item1, item2]))
    }

    func testInsertBeforeForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        player.insert(insertedItem, before: foreignItem)
        expect(player.items()).to(equalDiff([item]))
    }

    func testInsertBeforeNil() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.currentItem).to(equal(item))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, before: nil)
        expect(player.items()).to(equalDiff([insertedItem, item]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([insertedItem]))
    }

    func testInsertAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: item2)
        expect(player.items()).to(equalDiff([item1, item2, insertedItem, item3]))
        expect(player.nextItems()).to(equalDiff([item2, insertedItem, item3]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testInsertAfterCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: item2)
        expect(player.items()).to(equalDiff([item1, item2, insertedItem, item3]))
        expect(player.nextItems()).to(equalDiff([insertedItem, item3]))
        expect(player.previousItems()).to(equalDiff([item1]))
    }

    func testInsertAfterPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: item2)
        expect(player.items()).to(equalDiff([item1, item2, insertedItem, item3]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item1, item2, insertedItem]))
    }

    func testInsertAfterLastItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: item2)
        expect(player.items()).to(equalDiff([item1, item2, insertedItem]))
        expect(player.nextItems()).to(equalDiff([item2, insertedItem]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testInsertAfterIdenticalItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        player.insert(item1, after: item2)
        expect(player.items()).to(equalDiff([item1, item2]))
    }

    func testInsertAfterForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canInsert(insertedItem, after: foreignItem)).to(beFalse())
    }

    func testInsertAfterNil() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.currentItem).to(equal(item))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: nil)
        expect(player.items()).to(equalDiff([item, insertedItem]))
        expect(player.nextItems()).to(equalDiff([insertedItem]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testPrepend() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.currentItem).to(equal(item))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.prepend(insertedItem)
        expect(player.items()).to(equalDiff([insertedItem, item]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([insertedItem]))
    }

    func testAppend() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.currentItem).to(equal(item))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.append(insertedItem)
        expect(player.items()).to(equalDiff([item, insertedItem]))
        expect(player.nextItems()).to(equalDiff([insertedItem]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testCanMovePreviousItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item1, before: item3)).to(beTrue())
    }

    func testCanMovePreviousItemBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))
        expect(player.canMove(item1, before: item3)).to(beTrue())
    }

    func testCanMovePreviousItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))
        expect(player.canMove(item2, before: item1)).to(beTrue())
    }

    func testCanMoveCurrentItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item1, before: item3)).to(beTrue())
    }

    func testCanMoveCurrentItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item2, before: item1)).to(beTrue())
    }

    func testCanMoveNextItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item3, before: item1)).to(beTrue())
    }

    func testCanMoveNextItemBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item3, before: item2)).to(beTrue())
    }

    func testCanMoveNextItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item3, before: item2)).to(beTrue())
    }

    func testCannotMoveBeforeIdenticalItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canMove(item, before: item)).to(beFalse())
    }

    func testCannotMoveBeforeItemIfAlreadyAtExpectedLocation() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canMove(item1, before: item2)).to(beFalse())
    }

    func testCannotMoveForeignItemBeforeItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canMove(foreignItem, before: item)).to(beFalse())
    }

    func testCannotMoveItemBeforeForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canMove(item, before: foreignItem)).to(beFalse())
    }

    func testCanMoveBeforeFirstItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canMove(item2, before: item1)).to(beTrue())
    }

    func testCanMoveItemBeforeNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canMove(item2, before: nil)).to(beTrue())
    }

    func testCannotFirstItemBeforeNil() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canMove(item, before: nil)).to(beFalse())
    }

    func testMovePreviousItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item1, before: item3)
        expect(player.items()).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems()).to(equalDiff([item1, item3]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testMovePreviousItemBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        player.move(item1, before: item3)
        expect(player.items()).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item2, item1]))
    }

    func testMovePreviousItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        player.move(item2, before: item1)
        expect(player.items()).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item2, item1]))
    }

    func testMoveCurrentItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        player.move(item1, before: item3)
        expect(player.currentItem).to(equal(item2))
        expect(player.items()).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems()).to(equalDiff([item1, item3]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testMoveCurrentItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item2, before: item1)
        expect(player.currentItem).to(equal(item3))
        expect(player.items()).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item2, item1]))
    }

    func testMoveCurrentLastItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        player.move(item3, before: item1)
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(equalDiff([item3, item1, item2]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item3, item1, item2]))
    }

    func testMoveNextItemBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item3, before: item1)
        expect(player.items()).to(equalDiff([item3, item1, item2]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item3, item1]))
    }

    func testMoveNextItemBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item3, before: item2)
        expect(player.items()).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item1, item3]))
    }

    func testMoveNextItemBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        player.move(item3, before: item2)
        expect(player.items()).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems()).to(equalDiff([item3, item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testMoveBeforeIdenticalItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        player.move(item, before: item)
        expect(player.items()).to(equalDiff([item]))
    }

    func testMoveBeforeForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        player.move(item, before: foreignItem)
        expect(player.items()).to(equalDiff([item]))
    }

    func testMoveBeforeNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        player.move(item2, before: nil)
        expect(player.items()).to(equalDiff([item2, item1]))
    }

    func testCanMovePreviousItemAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item1, after: item3)).to(beTrue())
    }

    func testCanMovePreviousItemAfterCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item1, after: item2)).to(beTrue())
    }

    func testCanMovePreviousItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))
        expect(player.canMove(item1, after: item2)).to(beTrue())
    }

    func testCanMoveCurrentItemAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item1, after: item2)).to(beTrue())
    }

    func testCanMoveCurrentItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))
        expect(player.canMove(item3, after: item1)).to(beTrue())
    }

    func testCanMoveNextItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.canMove(item3, after: item1)).to(beTrue())
    }

    func testCanMoveNextItemAfterCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item3, after: item1)).to(beTrue())
    }

    func testCanMoveNextItemAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))
        expect(player.canMove(item2, after: item3)).to(beTrue())
    }

    func testCannotMoveAfterIdenticalItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canMove(item, after: item)).to(beFalse())
    }

    func testCannotMoveAfterItemIfAlreadyAtExpectedLocation() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canMove(item2, after: item1)).to(beFalse())
    }

    func testCannotMoveForeignItemAfterItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canMove(foreignItem, after: item)).to(beFalse())
    }

    func testCannotMoveItemAfterForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canMove(item, after: foreignItem)).to(beFalse())
    }

    func testCanMoveAfterLastItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canMove(item1, after: item2)).to(beTrue())
    }

    func testCanMoveItemAfterNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canMove(item1, after: nil)).to(beTrue())
    }

    func testCannotMoveLastItemAfterNil() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        expect(player.canMove(item, after: nil)).to(beFalse())
    }

    func testMovePreviousItemAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item1, after: item3)
        expect(player.items()).to(equalDiff([item2, item3, item1]))
        expect(player.nextItems()).to(equalDiff([item3, item1]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testMovePreviousItemAfterCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        player.move(item1, after: item3)
        expect(player.items()).to(equalDiff([item2, item3, item1]))
        expect(player.nextItems()).to(equalDiff([item1]))
        expect(player.previousItems()).to(equalDiff([item2]))
    }

    func testMovePreviousItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        player.move(item1, after: item2)
        expect(player.items()).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item2, item1]))
    }

    func testMoveCurrentItemAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        player.move(item1, after: item2)
        expect(player.currentItem).to(equal(item2))
        expect(player.items()).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems()).to(equalDiff([item1, item3]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testMoveCurrentItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        player.move(item3, after: item1)
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item1, item3, item2]))
    }

    func testMoveCurrentFirstItemAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        player.move(item1, after: item2)
        expect(player.currentItem).to(equal(item2))
        expect(player.items()).to(equalDiff([item2, item1, item3]))
        expect(player.nextItems()).to(equalDiff([item1, item3]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testMoveNextItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.move(item3, after: item1)
        expect(player.items()).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item1, item3]))
    }

    func testMoveNextItemAfterCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        player.move(item3, after: item1)
        expect(player.items()).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems()).to(equalDiff([item3, item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testMoveNextItemAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        player.move(item2, after: item3)
        expect(player.items()).to(equalDiff([item1, item3, item2]))
        expect(player.nextItems()).to(equalDiff([item3, item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testMoveAfterIdenticalItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        player.move(item, after: item)
        expect(player.items()).to(equalDiff([item]))
    }

    func testMoveAfterForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        player.move(item, after: foreignItem)
        expect(player.items()).to(equalDiff([item]))
    }

    func testMoveAfterNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        player.move(item1, after: nil)
        expect(player.items()).to(equalDiff([item2, item1]))
    }

    func testRemovePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.remove(item1)
        expect(player.items()).to(equalDiff([item2, item3]))
        expect(player.nextItems()).to(equalDiff([item3]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testRemoveCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.remove(item2)
        expect(player.currentItem).to(equal(item3))
        expect(player.items()).to(equalDiff([item1, item3]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item1]))
    }

    func testRemoveCurrentLastItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.remove(item2)
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(equalDiff([item1]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item1]))
    }

    func testRemoveNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.remove(item3)
        expect(player.items()).to(equalDiff([item1, item2]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item1]))
    }

    func testRemoveForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = DequePlayer(items: [item])
        player.remove(foreignItem)
        expect(player.items()).to(equalDiff([item]))
    }

    func testRemoveAllItems() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = DequePlayer(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        player.removeAllItems()
        expect(player.items()).to(beEmpty())
        expect(player.currentItem).to(beNil())
    }

    func testReturnToPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equalDiff([item1, item2]))
        expect(player.nextItems()).to(equalDiff([item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testReturnToPreviousItemAtFront() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equalDiff([item1, item2]))
        expect(player.nextItems()).to(equalDiff([item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testAdvanceToNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.items()).to(equalDiff([item1, item2]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item1]))
    }

    func testAdvanceToNextItemAtEnd() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        player.advanceToNextItem()
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(equalDiff([item]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equalDiff([item]))
    }
}
