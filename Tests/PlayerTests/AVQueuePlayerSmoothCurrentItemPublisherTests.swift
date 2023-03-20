//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Foundation

final class AVQueuePlayerSmoothCurrentItemPublisherTests: TestCase {
    func testEmpty() {
        let player = AVQueuePlayer()
        expectAtLeastEqualPublished(
            values: [.good(nil)],
            from: player.smoothCurrentItemPublisher()
        )
    }

    func testGoodItem() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.good(item)],
            from: player.smoothCurrentItemPublisher()
        )
    }

    func testGoodItemPlayedEntirely() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.good(item), .good(nil)],
            from: player.smoothCurrentItemPublisher()
        ) {
            player.play()
        }
    }

    func testBadItem() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVQueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.good(item), .bad(item)],
            from: player.smoothCurrentItemPublisher()
        )
    }

    func testGoodItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [.good(item1), .good(item2)],
            from: player.smoothCurrentItemPublisher()
        ) {
            player.play()
        }
    }

    func testBadItemAndGoodItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.unavailable.url)
        let item3 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectAtLeastEqualPublished(
            values: [.good(item1), .bad(item2), .good(item3)],
            from: player.smoothCurrentItemPublisher()
        ) {
            player.play()
        }
    }
}
