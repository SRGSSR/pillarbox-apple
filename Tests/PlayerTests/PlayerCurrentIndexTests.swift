//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import CoreMedia
import Nimble
import XCTest

final class PlayerCurrentIndexTests: XCTestCase {
    func testCurrentIndex() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(values: [0, 1], from: player.$currentIndex) {
            player.play()
        }
    }

    func testCurrentIndexWithEmptyPlayer() {
        let player = Player()
        expect(player.currentIndex).to(beNil())
    }

    func testSlowFirstCurrentIndex() {
        let item1 = PlayerItem.simple(url: Stream.shortOnDemand.url, delay: 2)
        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [0, 1],
            from: player.$currentIndex
        ) {
            player.play()
        }
    }

    func testCurrentIndexAfterPlayerEnded() {
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item])
        expectAtLeastEqualPublished(values: [0], from: player.$currentIndex) {
            player.play()
        }
    }

    func testSetCurrentIndex() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])

        expectAtLeastEqualPublished(values: [0, 1], from: player.$currentIndex) {
            try! player.setCurrentIndex(1)
        }
    }

    func testSetCurrentIndexUpdatePlayerCurrentItem() {
        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let item2 = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(items: [item1, item2])
        let publisher = player.queuePlayer.publisher(for: \.currentItem).compactMap { item -> URL? in
            guard let asset = item?.asset as? AVURLAsset else { return nil }
            return asset.url
        }

        expectAtLeastEqualPublished(values: [Stream.onDemand.url, Stream.shortOnDemand.url], from: publisher) {
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
        let publisher = player.queuePlayer.publisher(for: \.currentItem)

        expectNothingPublishedNext(from: publisher, during: 1) {
            try! player.setCurrentIndex(0)
        }
    }
}
