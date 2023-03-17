//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Foundation

final class SmoothCurrentItemPublisherTests: TestCase {
    func testEmpty() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(
            values: [.good(nil)],
            from: player.smoothCurrentItemPublisher()
        )
    }

    func testWithOneGoodItem() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)

        expectAtLeastEqualPublished(
            values: [.good(item)],
            from: player.smoothCurrentItemPublisher()
        )
    }

    func testWithOneGoodItemPlayedEntirely() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)

        expectAtLeastEqualPublished(
            values: [.good(item), .good(nil)],
            from: player.smoothCurrentItemPublisher()
        ) {
            player.play()
        }
    }

    func testWithOneBadItem() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = QueuePlayer(playerItem: item)

        expectAtLeastEqualPublished(
            values: [.good(item), .bad(item)],
            from: player.smoothCurrentItemPublisher()
        )
    }

    func testWithTwoGoodItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(items: [item1, item2])

        expectAtLeastEqualPublished(
            values: [.good(item1), .good(item2)],
            from: player.smoothCurrentItemPublisher()
        ) {
            player.play()
        }
    }
}
