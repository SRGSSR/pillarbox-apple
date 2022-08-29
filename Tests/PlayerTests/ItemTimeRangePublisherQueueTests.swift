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
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        expectPublished(
            values: [
                CMTimeRange(start: .zero, duration: CMTime(value: 1, timescale: 1)),
                CMTimeRange(start: .zero, duration: CMTime(value: 120, timescale: 1))
            ],
            from: player.itemTimeRangePublisher(configuration: PlayerConfiguration()),
            to: beClose(within: 0.5),
            during: 3
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
                CMTimeRange(start: .zero, duration: CMTime(value: 1, timescale: 1)),
                CMTimeRange(start: .zero, duration: CMTime(value: 120, timescale: 1))
            ],
            from: player.itemTimeRangePublisher(configuration: PlayerConfiguration()),
            to: beClose(within: 0.5),
            during: 3
        ) {
            player.play()
        }
    }
}
