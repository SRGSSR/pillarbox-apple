//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class QueueTests: TestCase {
    func testWhenEmpty() {
        let player = Player()
        expect(player.urls).to(beEmpty())
        expect(player.currentItem).to(beNil())
    }

    func testPlayableItem() {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expect(player.urls).toEventually(equal([
            Stream.shortOnDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    func testEntirePlayback() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(beNil())
    }

    func testFailingUnavailableItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        // Item is consumed by `AVQueuePlayer` for some reason.
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item))
    }

    func testFailingUnauthorizedItem() {
        let item = PlayerItem.simple(url: Stream.unauthorized.url)
        let player = Player(item: item)
        expect(player.urls).toEventually(equal([
            Stream.unauthorized.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    func testFailingMp3Item() {
        let item = PlayerItem.simple(url: Stream.unavailableMp3.url)
        let player = Player(item: item)
        expect(player.urls).toEventually(equal([
            Stream.unavailableMp3.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    func testBetweenPlayableItems() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.play()

        expect(player.urls).toEventually(equal([
            Stream.shortOnDemand.url,
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item1))

        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item2))
    }

    func testFailingUnavailableItemFollowedByPlayableItem() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        // Item is consumed by `AVQueuePlayer` for some reason.
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item1))
    }

    func testFailingUnauthorizedItemFollowedByPlayableItem() {
        let item1 = PlayerItem.simple(url: Stream.unauthorized.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.urls).toEventually(equal([
            Stream.unauthorized.url
        ]))
        expect(player.currentItem).to(equal(item1))
    }

    func testFailingMp3ItemFollowedByPlayableItem() {
        let item1 = PlayerItem.simple(url: Stream.unavailableMp3.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.urls).toEventually(equal([
            Stream.unavailableMp3.url
        ]))
        expect(player.currentItem).to(equal(item1))
    }

    func testFailingItemUnavailableBetweenPlayableItems() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.play()
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item2))
    }

    func testFailingUnauthorizedItemBetweenPlayableItems() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unauthorized.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.play()
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item2))
    }

    func testFailingMp3ItemBetweenPlayableItems() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailableMp3.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.play()
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item2))
    }

    func testPlayableItemReplacingFailingUnavailableItem() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        player.items = [item]
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    func testPlayableItemReplacingFailingUnauthorizedItem() {
        let player = Player(item: .simple(url: Stream.unauthorized.url))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        player.items = [item]
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    func testPlayableItemReplacingFailingMp3Item() {
        let player = Player(item: .simple(url: Stream.unavailableMp3.url))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        player.items = [item]
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    func testReplaceCurrentItem() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        player.items = [item]
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    func testRemoveCurrentItemFollowedByPlayableItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.remove(player.items.first!)
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item2))
    }

    func testRemoveAllItems() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.removeAllItems()
        expect(player.urls).to(beEmpty())
    }
}
