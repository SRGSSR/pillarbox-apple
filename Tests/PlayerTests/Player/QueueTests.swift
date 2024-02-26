//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import Nimble
import PillarboxStreams

final class QueueTests: TestCase {
    func testWhenEmpty() {
        let player = Player()
        expect(player.urls).to(beEmpty())
        expect(player.currentIndex).to(beNil())
    }

    func testPlayableItem() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        expect(player.urls).toEventually(equal([
            Stream.shortOnDemand.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    func testEntirePlayback() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.play()
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentIndex).to(beNil())
    }

    func testFailingUnavailableItem() {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url)
        ])
        // Item is consumed by `AVQueuePlayer` for some reason.
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentIndex).to(equal(0))
    }

    func testFailingUnauthorizedItem() {
        let player = Player(items: [
            .simple(url: Stream.unauthorized.url)
        ])
        expect(player.urls).toEventually(equal([
            Stream.unauthorized.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

    func testFailingMp3Item() {
        let player = Player(items: [
            .simple(url: Stream.unavailableMp3.url)
        ])
        expect(player.urls).toEventually(equal([
            Stream.unavailableMp3.url
        ]))
        expect(player.currentIndex).to(equal(0))
    }

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

    func testFailingUnavailableItemFollowedByPlayableItem() {
        let player = Player(items: [
            .simple(url: Stream.unavailable.url),
            .simple(url: Stream.onDemand.url)
        ])
        // Item is consumed by `AVQueuePlayer` for some reason.
        expect(player.urls).toEventually(beEmpty())
        expect(player.currentIndex).to(equal(0))
    }

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

    func testRemoveAllItems() {
        let player = Player(item: .simple(url: Stream.shortOnDemand.url))
        player.removeAllItems()
        expect(player.urls).to(beEmpty())
    }
}
