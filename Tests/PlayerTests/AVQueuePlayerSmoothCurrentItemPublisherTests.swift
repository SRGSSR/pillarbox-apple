//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Foundation

final class AVQueuePlayerSmoothCurrentItemPublisherTests: TestCase {
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
