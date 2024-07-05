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

final class CurrentIndexTests: TestCase {
    func testCurrentIndex() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        expectEqualPublished(values: [0, 1, nil], from: player.$currentIndex, during: .seconds(3)) {
            player.play()
        }
    }

    func testCurrentIndexWithFirstFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        expectEqualPublished(values: [0], from: player.$currentIndex, during: .milliseconds(500)) {
            player.play()
        }
    }

    func testCurrentIndexWithMiddleFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2, item3])
        expectEqualPublished(values: [0, 1], from: player.$currentIndex, during: .seconds(2)) {
            player.play()
        }
    }

    func testCurrentIndexWithLastFailedItem() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let player = Player(items: [item1, item2])
        expectEqualPublished(values: [0, 1], from: player.$currentIndex, during: .seconds(2)) {
            player.play()
        }
    }

    func testCurrentIndexWithFirstItemRemoved() {
        let item1 = PlayerItem.simple(url: Stream.unavailable.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expect(player.error).toEventuallyNot(beNil())
        player.remove(item1)
        expect(player.currentIndex).toAlways(equal(0), until: .seconds(1))
    }

    func testCurrentIndexWithSecondItemRemoved() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.unavailable.url)
        let item3 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2, item3])
        player.advanceToNextItem()
        expect(player.currentIndex).toEventually(equal(1))
        expect(player.error).toEventuallyNot(beNil())
        player.remove(item2)
        expect(player.currentIndex).toAlways(equal(1), until: .seconds(1))
    }

    func testCurrentIndexWithFailedItem() {
        let player = Player(item: .simple(url: Stream.unavailable.url))
        expectEqualPublished(values: [0], from: player.$currentIndex, during: .milliseconds(500))
    }

    func testCurrentIndexWithEmptyPlayer() {
        let player = Player()
        expect(player.currentIndex).to(beNil())
    }

    func testSlowFirstCurrentIndex() {
        let item1 = PlayerItem.mock(url: Stream.shortOnDemand.url, loadedAfter: 1)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectEqualPublished(values: [0, 1], from: player.$currentIndex, during: .seconds(3)) {
            player.play()
        }
    }

    func testCurrentIndexAfterPlayerEnded() {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item])
        expectEqualPublished(values: [0, nil], from: player.$currentIndex, during: .seconds(2)) {
            player.play()
        }
    }

    func testSetCurrentIndex() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        expectEqualPublished(values: [0, 1], from: player.$currentIndex, during: .milliseconds(500)) {
            try! player.setCurrentIndex(1)
        }
    }

    func testSetCurrentIndexUpdatePlayerCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        try! player.setCurrentIndex(1)
        expect(player.queuePlayer.currentItem?.url).toEventually(equal(Stream.shortOnDemand.url))
    }

    func testSetCurrentIndexToInvalidValue() {
        let player = Player()
        expect { try player.setCurrentIndex(1) }.to(throwError(PlaybackError.itemOutOfBounds))
    }

    func testPlayerPreloadedItemCount() {
        let player = Player(items: [
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.onDemand.url),
            PlayerItem.simple(url: Stream.onDemand.url)
        ])

        try! player.setCurrentIndex(2)

        let items = player.queuePlayer.items()
        expect(items.count).to(equal(player.configuration.preloadedItems))
    }
}
