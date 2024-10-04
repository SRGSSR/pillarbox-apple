//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class CurrentItemTests: TestCase {
    func testCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [item1, item2, nil],
            from: player.changePublisher(at: \.currentItem).removeDuplicates()
        ) {
            player.play()
        }
    }

    func testCurrentItemWithFirstFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        expectEqualPublished(
            values: [item1],
            from: player.changePublisher(at: \.currentItem).removeDuplicates(),
            during: .milliseconds(500)
        ) {
            player.play()
        }
    }

    func testCurrentItemWithMiddleFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2, item3])
        expectEqualPublished(
            values: [item1, item2],
            from: player.changePublisher(at: \.currentItem).removeDuplicates(),
            during: .seconds(2)
        ) {
            player.play()
        }
    }

    func testCurrentItemWithLastFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [item1, item2],
            from: player.changePublisher(at: \.currentItem).removeDuplicates()
        ) {
            player.play()
        }
    }

    func testCurrentItemWithFirstItemRemoved() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.error).toEventuallyNot(beNil())
        player.remove(item1)
        expect(player.currentItem).toAlways(equal(item2), until: .seconds(1))
    }

    func testCurrentItemWithSecondItemRemoved() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentItem).toEventually(equal(item2))
        expect(player.error).toEventuallyNot(beNil())
        player.remove(item2)
        expect(player.currentItem).toAlways(equal(item3), until: .seconds(1))
    }

    func testCurrentItemWithFailedItem() {
        let item = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(item: item)
        expectEqualPublished(
            values: [item],
            from: player.changePublisher(at: \.currentItem).removeDuplicates(),
            during: .milliseconds(500)
        )
    }

    func testCurrentItemWithEmptyPlayer() {
        let player = Player()
        expect(player.currentItem).to(beNil())
    }

    func testSlowFirstCurrentItem() {
        let item1 = PlayerItem.mock(url: Stream.shortOnDemand.url, loadedAfter: 1)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [item1, item2],
            from: player.changePublisher(at: \.currentItem).removeDuplicates()
        ) {
            player.play()
        }
    }

    func testCurrentItemAfterPlayerEnded() {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item])
        expectAtLeastEqualPublished(
            values: [item, nil],
            from: player.changePublisher(at: \.currentItem).removeDuplicates()
        ) {
            player.play()
        }
    }

    func testSetCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        expectEqualPublished(
            values: [item1, item2],
            from: player.changePublisher(at: \.currentItem).removeDuplicates(),
            during: .milliseconds(500)
        ) {
            player.currentItem = item2
        }
    }

    func testSetCurrentItemUpdatePlayerCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        player.currentItem = item2
        expect(player.queuePlayer.currentItem?.url).toEventually(equal(Stream.shortOnDemand.url))
    }

    func testPlayerPreloadedItemCount() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let item4 = PlayerItem.simple(url: Stream.onDemand.url)
        let item5 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3, item4, item5])
        player.currentItem = item3

        let items = player.queuePlayer.items()
        expect(items.count).to(equal(player.configuration.preloadedItems))
    }

    func testSetCurrentItemWithUnknownItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1])
        player.currentItem = item2
        expect(player.currentItem).toAlways(equal(item1), until: .seconds(1))
    }

    func testSetCurrentItemToNil() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expect(player.currentItem).to(equal(item))
        player.currentItem = nil
        expect(player.currentItem).to(beNil())
        expect(player.queuePlayer.items()).to(beEmpty())
    }
}
