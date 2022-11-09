//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemStatePublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectEqualPublished(
            // The second item can be pre-buffered and is immediately ready
            values: [.unknown, .readyToPlay, .ended, .readyToPlay, .ended],
            from: player.itemStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.unavailable.url)
        let item3 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectEqualPublished(
            // The third item cannot be pre-buffered and goes through the usual states
            values: [
                .unknown, .readyToPlay, .ended,
                .failed(error: PlayerError.resourceNotFound),
                .unknown, .readyToPlay, .ended
            ],
            from: player.itemStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }
}
