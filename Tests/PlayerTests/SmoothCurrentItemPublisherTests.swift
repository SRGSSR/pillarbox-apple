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
        expectEqualPublished(
            values: [.good(nil)],
            from: player.smoothCurrentItemPublisher(),
            during: 2
        )
    }

    func testWithOneGoodItem() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)

        expectEqualPublished(
            values: [.good(item)],
            from: player.smoothCurrentItemPublisher(),
            during: 2
        ) {
            player.play()
        }
    }
}
