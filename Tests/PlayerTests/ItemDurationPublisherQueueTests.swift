//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemDurationPublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemand.url)
        let item2 = AVPlayerItem(url: TestStreams.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectPublished(
            values: [
                .indefinite,
                TestStreams.shortOnDemand.duration,
                // Next media can be prepared and is immediately ready
                TestStreams.onDemand.duration
            ],
            from: player.itemDurationPublisher()
                .removeDuplicates(by: CMTime.close(within: 1)),
            to: beClose(within: 1),
            during: 4
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemand.url)
        let item2 = AVPlayerItem(url: TestStreams.unavailable.url)
        let item3 = AVPlayerItem(url: TestStreams.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectPublished(
            values: [
                .indefinite,
                TestStreams.shortOnDemand.duration,
                // Next media cannot be prepared because of the failure
                .indefinite,
                TestStreams.onDemand.duration
            ],
            from: player.itemDurationPublisher()
                .removeDuplicates(by: CMTime.close(within: 1)),
            to: beClose(within: 1),
            during: 4
        ) {
            player.play()
        }
    }
}
