//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class QueueTests: TestCase {
    @MainActor
    func testWhenEmpty() {
        let player = Player()
        expect(player.urls).to(beEmpty())
        expect(player.currentIndex).to(beNil())
    }

    @MainActor
    func testPlayableItem() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.urls).toEventually(equal([
            Stream.shortOnDemand.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testEntirePlayback() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentIndex).to(beNil())
    }

    @MainActor
    func testFailingUnavailableItem() {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url)
        ])
        // Item is consumed by `AVQueuePlayer` for some reason.
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testFailingUnauthorizedItem() {
        let player = Player(items: [
            .simple(url: Stream.unauthorized.url)
        ])
        expect(player.urls).toEventually(equal([
            Stream.unauthorized.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testFailingMp3Item() {
        let player = Player(items: [
            .simple(url: Stream.unavailableMp3.url)
        ])
        expect(player.urls).toEventually(equal([
            Stream.unavailableMp3.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testBetweenPlayableItems() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.onDemand.url)
        ])
        player.play()

        expect(player.urls).toEventually(equal([
            Stream.shortOnDemand.url,
            Stream.onDemand.url
        ]))
        expect(player.currentIndex).to(equal(0))

        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentIndex).to(equal(1))
    }

    @MainActor
    func testFailingUnavailableItemFollowedByPlayableItem() {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url),
            .simple(url: Stream.onDemand.url)
        ])
        // Item is consumed by `AVQueuePlayer` for some reason.
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testFailingUnauthorizedItemFollowedByPlayableItem() {
        let player = Player(items: [
            .simple(url: Stream.unauthorized.url),
            .simple(url: Stream.onDemand.url)
        ])
        expect(player.urls).toEventually(equal([
            Stream.unauthorized.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testFailingMp3ItemFollowedByPlayableItem() {
        let player = Player(items: [
            .simple(url: Stream.unavailableMp3.url),
            .simple(url: Stream.onDemand.url)
        ])
        expect(player.urls).toEventually(equal([
            Stream.unavailableMp3.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testFailingItemUnavailableBetweenPlayableItems() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.unavailable.url),
            .simple(url: Stream.onDemand.url)
        ])
        player.play()
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentIndex).to(equal(1))
    }

    @MainActor
    func testFailingUnauthorizedItemBetweenPlayableItems() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.unauthorized.url),
            .simple(url: Stream.onDemand.url)
        ])
        player.play()
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentIndex).to(equal(1))
    }

    @MainActor
    func testFailingMp3ItemBetweenPlayableItems() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.unavailableMp3.url),
            .simple(url: Stream.onDemand.url)
        ])
        player.play()
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentIndex).to(equal(1))
    }

    @MainActor
    func testPlayableItemReplacingFailingUnavailableItem() {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url)
        ])
        player.items = [.simple(url: Stream.onDemand.url)]
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testPlayableItemReplacingFailingUnauthorizedItem() {
        let player = Player(items: [
            .simple(url: Stream.unauthorized.url)
        ])
        player.items = [.simple(url: Stream.onDemand.url)]
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testPlayableItemReplacingFailingMp3Item() {
        let player = Player(items: [
            .simple(url: Stream.unavailableMp3.url)
        ])
        player.items = [.simple(url: Stream.onDemand.url)]
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testReplaceCurrentItem() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url)
        ])
        player.items = [.simple(url: Stream.onDemand.url)]
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testRemoveCurrentItemFollowedByPlayableItem() {
        let player = Player(items: [
            .simple(url: Stream.shortOnDemand.url),
            .simple(url: Stream.onDemand.url)
        ])
        player.remove(player.items.first!)
        expect(player.urls).toEventually(equal([
            Stream.onDemand.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    @MainActor
    func testRemoveAllItems() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.removeAllItems()
        expect(player.urls).to(beEmpty())
    }
}
