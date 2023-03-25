//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Foundation

final class AVPlayerSmoothCurrentItemPublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [.good(nil)],
            from: player.smoothCurrentItemPublisher()
        )
    }

    func testGoodItem() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.good(item)],
            from: player.smoothCurrentItemPublisher()
        )
    }

    func testGoodItemPlayedEntirely() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.good(item)],
            from: player.smoothCurrentItemPublisher()
        ) {
            player.play()
        }
    }

    func testBadItem() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.good(item)],
            from: player.smoothCurrentItemPublisher()
        )
    }
}
