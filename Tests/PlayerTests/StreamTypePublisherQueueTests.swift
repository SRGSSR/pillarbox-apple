//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class StreamTypePublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectEqualPublished(
            values: [.unknown, .onDemand],
            from: player.streamTypePublisher(),
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
        expectEqualPublished(
            values: [.unknown, .onDemand, .unknown, .onDemand],
            from: player.streamTypePublisher(),
            during: 3
        ) {
            player.play()
        }
    }
}
