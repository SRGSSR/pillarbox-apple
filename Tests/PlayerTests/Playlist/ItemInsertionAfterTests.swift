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
    @MainActor
    func testInsertItemAfterNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
    }

    @MainActor
    func testInsertItemAfterCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
    }

    @MainActor
    func testInsertItemAfterPreviousItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem, item3]))
    }

    @MainActor
    func testInsertItemAfterLastItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: item2)).to(beTrue())
        expect(player.items).to(equalDiff([item1, item2, insertedItem]))
    }

    @MainActor
    func testInsertItemAfterIdenticalItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.insert(item1, after: item2)).to(beFalse())
        expect(player.items).to(equalDiff([item1, item2]))
    }

    @MainActor
    func testInsertItemAfterForeignItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        let foreignItem = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        expect(player.insert(insertedItem, after: foreignItem)).to(beFalse())
        expect(player.items).to(equalDiff([item]))
    }

    @MainActor
    func testInsertItemAfterNil() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.insert(insertedItem, after: nil)).to(beTrue())
        expect(player.items).to(equalDiff([item, insertedItem]))
    }

    @MainActor
    func testAppendItem() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item])
        let insertedItem = PlayerItem.simple(url: Stream.onDemand.url)
        expect(player.append(insertedItem)).to(beTrue())
        expect(player.items).to(equalDiff([item, insertedItem]))
    }
}
