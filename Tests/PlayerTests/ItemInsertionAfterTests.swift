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
final class ItemInsertionAfterTests: XCTestCase {
    func testInsertAfterNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: item2)
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
        expect(player.nextItems).to(equalDiff([item2, insertedItem, item3]))
        expect(player.previousItems).to(beEmpty())
    }

    func testInsertAfterCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: item2)
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
        expect(player.nextItems).to(equalDiff([insertedItem, item3]))
        expect(player.previousItems).to(equalDiff([item1]))
    }

    func testInsertAfterPreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: item2)
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item1, item2, insertedItem]))
    }

    func testInsertAfterLastItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: item2)
        expect(player.items).to(equalDiff([item1, item2, insertedItem]))
        expect(player.nextItems).to(equalDiff([item2, insertedItem]))
        expect(player.previousItems).to(beEmpty())
    }

    func testInsertAfterIdenticalItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])
        player.insert(item1, after: item2)
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testInsertAfterForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = Player(items: [item])
        expect(player.canInsert(insertedItem, after: foreignItem)).to(beFalse())
    }

    func testInsertAfterNil() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(items: [item])
        expect(player.currentItem).to(equal(item))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.insert(insertedItem, after: nil)
        expect(player.items).to(equalDiff([item, insertedItem]))
        expect(player.nextItems).to(equalDiff([insertedItem]))
        expect(player.previousItems).to(beEmpty())
    }

    func testPrepend() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(items: [item])
        expect(player.currentItem).to(equal(item))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.prepend(insertedItem)
        expect(player.items).to(equalDiff([insertedItem, item]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([insertedItem]))
    }

    func testAppend() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(items: [item])
        expect(player.currentItem).to(equal(item))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        player.append(insertedItem)
        expect(player.items).to(equalDiff([item, insertedItem]))
        expect(player.nextItems).to(equalDiff([insertedItem]))
        expect(player.previousItems).to(beEmpty())
    }
}
