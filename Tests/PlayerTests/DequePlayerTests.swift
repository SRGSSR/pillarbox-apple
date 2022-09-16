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
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, before: item1)).to(beTrue())
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
        expect(player.canInsert(insertedItem, before: player.currentItem)).to(beTrue())
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
        expect(player.canInsert(insertedItem, before: item1)).to(beTrue())
        expect(player.canInsert(insertedItem, before: item2)).to(beTrue())
    }

    func testCanInsertBeforeSameItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canInsert(item1, before: item1)).to(beFalse())
        expect(player.canInsert(item1, before: item2)).to(beFalse())
    }

    func testCanInsertBeforeForeignItem() {
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
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.canInsert(insertedItem, after: item1)).to(beTrue())
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
        expect(player.canInsert(insertedItem, after: player.currentItem)).to(beTrue())
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
        expect(player.canInsert(insertedItem, after: item1)).to(beTrue())
        expect(player.canInsert(insertedItem, after: item2)).to(beTrue())
    }

    func testCanInsertAfterSameItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        expect(player.canInsert(item1, after: item1)).to(beFalse())
        expect(player.canInsert(item1, after: item2)).to(beFalse())
    }

    func testCanInsertAfterForeignItem() {
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
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, before: item1)
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([insertedItem, item1, item2]))
        expect(player.nextItems()).to(equal([item2]))
        expect(player.previousItems()).to(equal([insertedItem]))
    }

    func testInsertBeforeCurrentItem() {
    }

    func testInsertBeforePreviousItem() {
    }

    func testInsertBeforeSameItem() {
    }

    func testInsertBeforeForeignItem() {
    }

    func testInsertBeforeNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let player = DequePlayer(items: [item1])
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.insert(item2, before: nil)
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item2, item1]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equal([item2]))
    }

    func testInsertAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: item1)
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item1, insertedItem, item2]))
        expect(player.nextItems()).to(equal([insertedItem, item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testInsertAfterCurrentItem() {
    }

    func testInsertAfterPreviousItem() {
    }

    func testInsertAfterSameItem() {
    }

    func testInsertAfterForeignItem() {
    }

    func testInsertAfterNil() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let player = DequePlayer(items: [item1])
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        player.insert(item2, after: nil)
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item1, item2]))
        expect(player.nextItems()).to(equal([item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testPrepend() {
    }

    func testPrependSame() {
    }

    func testAppend() {
    }

    func testAppendSame() {
    }

    func testMovePreviousItemBeforePreviousItem() {
    }

    func testMovePreviousItemBeforeCurrentItem() {
    }

    func testMovePreviousItemBeforeNextItem() {
    }

    func testMoveCurrentItemBeforePreviousItem() {
    }

    func testMoveCurrentItemBeforeCurrentItem() {
    }

    func testMoveCurrentItemBeforeNextItem() {
    }

    func testMoveNextItemBeforePreviousItem() {
    }

    func testMoveNextItemBeforeCurrentItem() {
    }

    func testMoveNextItemBeforeNextItem() {
    }

    func testMoveBeforeSamePreviousItem() {
    }

    func testMoveBeforeSameCurrentItem() {
    }

    func testMoveBeforeSameNextItem() {
    }

    func testMoveBeforeForeignItem() {
    }

    func testMoveBeforeNil() {
    }

    func testMovePreviousItemAfterPreviousItem() {
    }

    func testMovePreviousItemAfterCurrentItem() {
    }

    func testMovePreviousItemAfterNextItem() {
    }

    func testMoveCurrentItemAfterPreviousItem() {
    }

    func testMoveCurrentItemAfterCurrentItem() {
    }

    func testMoveCurrentItemAfterNextItem() {
    }

    func testMoveNextItemAfterPreviousItem() {
    }

    func testMoveNextItemAfterCurrentItem() {
    }

    func testMoveNextItemAfterNextItem() {
    }

    func testMoveAfterSamePreviousItem() {
    }

    func testMoveAfterSameCurrentItem() {
    }

    func testMoveAfterSameNextItem() {
    }

    func testMoveAfterForeignItem() {
    }

    func testMoveAfterNil() {
    }

    func testRemovePreviousItem() {
    }

    func testRemoveCurrentItem() {
    }

    func testRemoveNextItem() {
    }

    func testRemoveForeignItem() {
    }

    func testRemoveAllItems() {
    }

    func testReturnToPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        player.advanceToNextItem()
        player.returnToPreviousItem()
        expect(player.currentItem).to(equal(item1))
        expect(player.items()).to(equal([item1, item2]))
        expect(player.nextItems()).to(equal([item2]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testReturnToPreviousItemAtFront() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        player.returnToPreviousItem()
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(beNil())
        expect(player.nextItems()).to(equal([item]))
        expect(player.previousItems()).to(beEmpty())
    }

    func testAdvanceToNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = DequePlayer(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))
        expect(player.items()).to(equal([item1, item2]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equal([item1]))
    }

    func testAdvanceToNextItemAtEnd() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = DequePlayer(items: [item])
        player.advanceToNextItem()
        expect(player.currentItem).to(beNil())
        expect(player.items()).to(equal([item]))
        expect(player.nextItems()).to(beEmpty())
        expect(player.previousItems()).to(equal([item]))
    }
}
