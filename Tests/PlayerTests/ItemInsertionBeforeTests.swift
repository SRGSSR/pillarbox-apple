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
final class ItemInsertionBeforeTests: XCTestCase {
    func testInsertBeforeNextItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.insert(insertedItem, before: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, insertedItem, item2]))
        expect(player.nextItems).to(equalDiff([insertedItem, item2]))
        expect(player.previousItems).to(beEmpty())
    }

    func testInsertBeforeCurrentItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item2))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.insert(insertedItem, before: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, insertedItem, item2, item3]))
        expect(player.nextItems).to(equalDiff([item3]))
        expect(player.previousItems).to(equalDiff([item1, insertedItem]))
    }

    func testInsertBeforePreviousItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let item3 = AVPlayerItem(url: URL(string: "https://www.server.com/item3.m3u8")!)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentItem).to(equal(item3))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.insert(insertedItem, before: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, insertedItem, item2, item3]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([item1, insertedItem, item2]))
    }

    func testInsertBeforeFirstItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])
        expect(player.currentItem).to(equal(item1))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.insert(insertedItem, before: item1)).to(beTrue())
        expect(player.items).to(equalDiff([insertedItem, item1, item2]))
        expect(player.nextItems).to(equalDiff([item2]))
        expect(player.previousItems).to(equalDiff([insertedItem]))
    }

    func testInsertBeforeIdenticalItem() {
        let item1 = AVPlayerItem(url: URL(string: "https://www.server.com/item1.m3u8")!)
        let item2 = AVPlayerItem(url: URL(string: "https://www.server.com/item2.m3u8")!)
        let player = Player(items: [item1, item2])
        expect(player.insert(item1, before: item2)).to(beFalse())
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testInsertBeforeForeignItem() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        let foreignItem = AVPlayerItem(url: URL(string: "https://www.server.com/foreign.m3u8")!)
        let player = Player(items: [item])
        expect(player.insert(insertedItem, before: foreignItem)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testInsertBeforeNil() {
        let item = AVPlayerItem(url: URL(string: "https://www.server.com/item.m3u8")!)
        let player = Player(items: [item])
        expect(player.currentItem).to(equal(item))

        let insertedItem = AVPlayerItem(url: URL(string: "https://www.server.com/inserted.m3u8")!)
        expect(player.insert(insertedItem, before: nil)).to(beTrue())
        expect(player.items).to(equalDiff([insertedItem, item]))
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(equalDiff([insertedItem]))
    }
}
