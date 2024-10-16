//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class ItemInsertionAfterTests: TestCase {
    func testInsertItemAfterNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equal([item1, item2, insertedItem, item3]))
    }

    func testInsertItemAfterCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equal([item1, item2, insertedItem, item3]))
    }

    func testInsertItemAfterPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equal([item1, item2, insertedItem, item3]))
    }

    func testInsertItemAfterLastItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equal([item1, item2, insertedItem]))
    }

    func testInsertItemAfterIdenticalItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.insert(item1, after: item2)).to(beFalse())
        expect(player.items).to(equal([item1, item2]))
    }

    func testInsertItemAfterForeignItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        let foreignItem = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        expect(player.insert(insertedItem, after: foreignItem)).to(beFalse())
        expect(player.items).to(equal([item]))
    }

    func testInsertItemAfterNil() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: nil)).to(beTrue())
        expect(player.items).to(equal([item, insertedItem]))
    }

    func testAppendItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.append(insertedItem)).to(beTrue())
        expect(player.items).to(equal([item, insertedItem]))
    }
}
