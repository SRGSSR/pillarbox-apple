//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemDurationPublisherQueueTests: TestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectPublished(
            values: [
                .invalid,
                Stream.shortOnDemand.duration,
                // Next media can be prepared and is immediately ready
                Stream.onDemand.duration
            ],
            from: player.currentItemDurationPublisher()
                .removeDuplicates(by: CMTime.close(within: 1)),
            to: beClose(within: 1),
            during: .seconds(4)
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
                .invalid,
                Stream.shortOnDemand.duration,
                // Next media cannot be prepared because of the failure
                .invalid,
                Stream.onDemand.duration
            ],
            from: player.currentItemDurationPublisher()
                .removeDuplicates(by: CMTime.close(within: 1)),
            to: beClose(within: 1),
            during: .seconds(4)
        ) {
            player.play()
        }
    }
}
