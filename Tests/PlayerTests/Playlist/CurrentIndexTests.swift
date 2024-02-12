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
        let publisher = player.queuePlayer.currentItemPublisher().compactMap(\.?.url)
        expectEqualPublishedNext(values: [Resource.loadingUrl, Stream.shortOnDemand.url], from: publisher, during: .seconds(1)) {
            try! player.setCurrentIndex(1)
        }
    }

    func testSetCurrentIndexToInvalidValue() {
        let player = Player()
        expect { try player.setCurrentIndex(1) }.to(throwError(PlaybackError.itemOutOfBounds))
    }

    func testSetCurrentIndexToSameValue() {
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        let publisher = player.queuePlayer.currentItemPublisher().compactMap(\.?.url)
        expectAtLeastEqualPublishedNext(values: [Resource.loadingUrl], from: publisher) {
            try! player.setCurrentIndex(0)
        }
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
