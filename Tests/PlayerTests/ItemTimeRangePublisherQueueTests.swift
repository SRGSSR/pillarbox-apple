//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemTimeRangePublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectPublished(
            values: [
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration),
                CMTimeRange(start: .zero, duration: Stream.onDemand.duration)
            ],
            from: player.itemTimeRangePublisher(),
            to: beClose(within: 1),
            during: 3
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.unavailable.url)
        let item3 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectPublished(
            values: [
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration),
                CMTimeRange(start: .zero, duration: Stream.onDemand.duration)
            ],
            from: player.itemTimeRangePublisher(),
            to: beClose(within: 1),
            during: 3
        ) {
            player.play()
        }
    }
}
