//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class ItemsTests: TestCase {
    func testItemsOnFirstItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        expect(player.items).to(equalDiff([item1, item2, item3]))
        expect(player.previousItems).to(beEmpty())
        expect(player.nextItems).to(equalDiff([item2, item3]))
    }

    func testItemsOnMiddleItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.items).to(equalDiff([item1, item2, item3]))
        expect(player.previousItems).to(equalDiff([item1]))
        expect(player.nextItems).to(equalDiff([item3]))
    }

    func testItemsOnLastItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.items).to(equalDiff([item1, item2, item3]))
        expect(player.previousItems).to(equalDiff([item1, item2]))
        expect(player.nextItems).to(beEmpty())
    }

    func testEmpty() {
        let player = Player()
        expect(player.currentItem).to(beNil())
        expect(player.items).to(beEmpty())
        expect(player.nextItems).to(beEmpty())
        expect(player.previousItems).to(beEmpty())
    }

    func testRemoveAll() {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expect(player.currentItem).to(equal(item))
        player.removeAllItems()
        expect(player.currentItem).to(beNil())
    }

    func testAppendAfterRemoveAll() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.removeAllItems()
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        player.append(item)
        expect(player.currentItem).to(equal(item))
    }
}
