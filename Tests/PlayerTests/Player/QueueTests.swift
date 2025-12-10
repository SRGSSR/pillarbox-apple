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

    @MainActor
    func testPlayableItem() async {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        await expect(player.urls).toEventually(equal([
            Stream.shortOnDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testEntirePlayback() async {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        await expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(beNil())
    }

    @MainActor
    func testFailingUnavailableItem() async {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        await expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testFailingUnauthorizedItem() async {
        let item = PlayerItem.simple(url: Stream.unauthorized.url)
        let player = Player(item: item)
        await expect(player.urls).toEventually(equal([
            Stream.unauthorized.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testFailingMp3Item() async {
        let item = PlayerItem.simple(url: Stream.unavailableMp3.url)
        let player = Player(item: item)
        await expect(player.urls).toEventually(equal([
            Stream.unavailableMp3.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testBetweenPlayableItems() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.play()

        await expect(player.urls).toEventually(equal([
            Stream.shortOnDemand.url,
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item1))

        await expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item2))
    }

    @MainActor
    func testFailingUnavailableItemFollowedByPlayableItem() async {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        await expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item1))
    }

    @MainActor
    func testFailingUnauthorizedItemFollowedByPlayableItem() async {
        let item1 = PlayerItem.simple(url: Stream.unauthorized.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        await expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item1))
    }

    @MainActor
    func testFailingMp3ItemFollowedByPlayableItem() async {
        let item1 = PlayerItem.simple(url: Stream.unavailableMp3.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        await expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item1))
    }

    @MainActor
    func testFailingItemUnavailableBetweenPlayableItems() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.play()
        await expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item2))
    }

    @MainActor
    func testFailingMp3ItemBetweenPlayableItems() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailableMp3.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.play()
        await expect(player.urls).toEventually(beEmpty())
        expect(player.currentItem).to(equal(item2))
    }

    @MainActor
    func testPlayableItemReplacingFailingUnavailableItem() async {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        player.items = [item]
        await expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testPlayableItemReplacingFailingUnauthorizedItem() async {
        let player = Player(item: .simple(url: Stream.unauthorized.url))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        player.items = [item]
        await expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testPlayableItemReplacingFailingMp3Item() async {
        let player = Player(item: .simple(url: Stream.unavailableMp3.url))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        player.items = [item]
        await expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testReplaceCurrentItem() async {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        player.items = [item]
        await expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentItem).to(equal(item))
    }

    @MainActor
    func testRemoveCurrentItemFollowedByPlayableItem() async {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.remove(player.items.first!)
        await expect(player.urls).toEventually(equal([
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
