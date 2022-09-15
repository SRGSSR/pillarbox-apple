//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class BufferingPublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemand.url)
        let item2 = AVPlayerItem(url: TestStreams.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectEqualPublished(
            // Next media can be buffered in advance
            values: [false, true, false],
            from: player.bufferingPublisher(),
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
        expectEqualPublished(
            // Next media cannot be buffered in advance because of the failure
            values: [false, true, false, true, false],
            from: player.bufferingPublisher(),
            during: 4
        ) {
            player.play()
        }
    }
}
