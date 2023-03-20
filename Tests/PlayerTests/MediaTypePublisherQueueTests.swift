//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class MediaTypePublisherQueueTests: TestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: Stream.mp3.url)
        let item2 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [.unknown, .audio, .unknown, .video],
            from: player.mediaTypePublisher()
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.unavailable.url)
        let item3 = AVPlayerItem(url: Stream.mp3.url)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectAtLeastEqualPublished(
            values: [.unknown, .video, .unknown, .audio],
            from: player.mediaTypePublisher()
        ) {
            player.play()
        }
    }
}
