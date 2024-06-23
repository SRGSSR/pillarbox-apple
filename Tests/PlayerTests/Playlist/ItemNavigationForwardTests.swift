//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Nimble
import PillarboxStreams

final class ItemNavigationForwardTests: TestCase {
    @MainActor
    func testAdvanceToNextItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        expect(player.currentIndex).to(equal(1))
    }

    @MainActor
    func testAdvanceToNextItemAtBack() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentIndex).to(equal(1))
    }

    @MainActor
    func testAdvanceToNextItemOnFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        player.advanceToNextItem()
        expect(player.currentIndex).to(equal(2))
    }

    @MainActor
    func testPlayerPreloadedItemCount() {
        let player = Player(items: [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.squareOnDemand.url),
            PlayerItem.simple(url: Stream.mediumOnDemand.url),
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.shortOnDemand.url)
        ])
        player.advanceToNextItem()

        let items = player.queuePlayer.items()
        expect(items.count).to(equal(player.configuration.preloadedItems))
    }
}
