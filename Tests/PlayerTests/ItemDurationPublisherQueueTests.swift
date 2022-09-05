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
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        expectPublished(
            values: [
                .indefinite,
                CMTime(value: 1, timescale: 1),
                // Next media can be prepared and is immediately ready
                CMTime(value: 120, timescale: 1)
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
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectPublished(
            values: [
                .indefinite,
                CMTime(value: 1, timescale: 1),
                // Next media cannot be prepared because of the failure
                .indefinite,
                CMTime(value: 120, timescale: 1)
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
