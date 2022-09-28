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
final class ItemInsertionAfterCheckTests: XCTestCase {
    func testCanInsertAfterNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.canInsert(insertedItem, after: item2)).to(beTrue())
    }

    func testCanInsertAfterCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.canInsert(insertedItem, after: item2)).to(beTrue())
    }

    func testCanInsertAfterPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.canInsert(insertedItem, after: item2)).to(beTrue())
    }

    func testCanInsertAfterLastItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.canInsert(insertedItem, after: item2)).to(beTrue())
    }

    func testCannotInsertAfterIdenticalItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.canInsert(item1, after: item2)).to(beFalse())
    }

    func testCannotInsertAfterForeignItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        let foreignItem = AVPlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.canInsert(insertedItem, after: foreignItem)).to(beFalse())
    }

    func testCanInsertAfterNil() {
        let item = AVPlayerItem(url: Stream.item.url)
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        let player = Player(items: [item])
        expect(player.canInsert(insertedItem, after: nil)).to(beTrue())
    }
}
