//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class ItemInsertionBeforeTests: TestCase {
    func testInsertItemBeforeNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, before: item2)).to(beTrue())
        expect(player.items).to(equal([item1, insertedItem, item2, item3]))
    }

    func testInsertItemBeforeCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, before: item2)).to(beTrue())
        expect(player.items).to(equal([item1, insertedItem, item2, item3]))
    }

    func testInsertItemBeforePreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, before: item2)).to(beTrue())
        expect(player.items).to(equal([item1, insertedItem, item2, item3]))
    }

    func testInsertItemBeforeFirstItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, before: item1)).to(beTrue())
        expect(player.items).to(equal([insertedItem, item1, item2]))
    }

    func testInsertItemBeforeIdenticalItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.insert(item1, before: item2)).to(beFalse())
        expect(player.items).to(equal([item1, item2]))
    }

    func testInsertItemBeforeForeignItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        let foreignItem = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        expect(player.insert(insertedItem, before: foreignItem)).to(beFalse())
        expect(player.items).to(equal([item]))
    }

    func testInsertItemBeforeNil() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, before: nil)).to(beTrue())
        expect(player.items).to(equal([insertedItem, item]))
    }

    func testPrependItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.prepend(insertedItem)).to(beTrue())
        expect(player.items).to(equal([insertedItem, item]))
    }
}
