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
    func testInsertItemAfterNextItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
    }

    func testInsertItemAfterCurrentItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
    }

    func testInsertItemAfterPreviousItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let item3 = AVPlayerItem(url: Stream.item(numbered: 3).url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
    }

    func testInsertItemAfterLastItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem]))
    }

    func testInsertItemAfterIdenticalItem() {
        let item1 = AVPlayerItem(url: Stream.item(numbered: 1).url)
        let item2 = AVPlayerItem(url: Stream.item(numbered: 2).url)
        let player = Player(items: [item1, item2])
        expect(player.insert(item1, after: item2)).to(beFalse())
        expect(player.items).to(equalDiff([item1, item2]))
    }

    func testInsertItemAfterForeignItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        let foreignItem = AVPlayerItem(url: Stream.foreignItem.url)
        let player = Player(items: [item])
        expect(player.insert(insertedItem, after: foreignItem)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    func testInsertItemAfterNil() {
        let item = AVPlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.insert(insertedItem, after: nil)).to(beTrue())
        expect(player.items).to(equalDiff([item, insertedItem]))
    }

    func testAppendItem() {
        let item = AVPlayerItem(url: Stream.item.url)
        let player = Player(items: [item])
        let insertedItem = AVPlayerItem(url: Stream.insertedItem.url)
        expect(player.append(insertedItem)).to(beTrue())
        expect(player.items).to(equalDiff([item, insertedItem]))
    }
}
