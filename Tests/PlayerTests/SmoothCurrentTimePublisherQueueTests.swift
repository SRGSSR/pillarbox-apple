//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

final class SmoothCurrentTimePublisherQueueTests: TestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(items: [item1, item2])
        expectPublished(
            values: [
                .zero, CMTime(value: 1, timescale: 2), CMTime(value: 1, timescale: 1),
                .zero, CMTime(value: 1, timescale: 2), CMTime(value: 1, timescale: 1)
            ],
            from: player.smoothCurrentTimePublisher(interval: CMTime(value: 1, timescale: 2), queue: .main),
            to: beClose(within: 0.3),
            during: .seconds(4)
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.unavailable.url)
        let item3 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(items: [item1, item2, item3])
        expectPublished(
            values: [
                .zero, CMTime(value: 1, timescale: 2), CMTime(value: 1, timescale: 1),
                .zero, CMTime(value: 1, timescale: 2), CMTime(value: 1, timescale: 1)
            ],
            from: player.smoothCurrentTimePublisher(interval: CMTime(value: 1, timescale: 2), queue: .main),
            to: beClose(within: 0.3),
            during: .seconds(4)
        ) {
            player.play()
        }
    }
}
