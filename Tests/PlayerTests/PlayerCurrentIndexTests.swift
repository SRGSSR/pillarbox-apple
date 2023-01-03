//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
import CoreMedia
import Nimble
import XCTest

@MainActor
final class PlayerCurrentIndexTests: XCTestCase {
    func testCurrentIndex() {
        let item1 = PlayerItem(url: Stream.shortOnDemand.url)
        let item2 = PlayerItem(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(values: [0, 1], from: player.$currentIndex
        ) {
            player.play()
        }
    }

    func testCurrentIndexWithEmptyPlayer() {
        let player = Player()
        expect(player.currentIndex).to(beNil())
    }

    func testSlowFirstCurrentIndex() {
        let item1 = PlayerItem(url: Stream.shortOnDemand.url, delay: 2)
        let item2 = PlayerItem(url: Stream.onDemand.url)
        let player = Player(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [0, 1],
            from: player.$currentIndex
        ) {
            player.play()
        }
    }

    func testCurrentIndexAfterPlayerEnded() {
        let item = PlayerItem(url: Stream.shortOnDemand.url)
        let player = Player(items: [item])
        expectAtLeastEqualPublished(values: [0], from: player.$currentIndex
        ) {
            player.play()
        }
    }
}
