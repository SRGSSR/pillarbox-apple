//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class PlaybackStatePublisherQueueTests: XCTestCase {
    func testItems() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        expectEqualPublished(
            // The second item can be pre-buffered and is immediately played
            values: [.idle, .playing, .ended, .playing, .ended],
            from: player.playbackStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        expectEqualPublished(
            // The third item cannot be pre-buffered and goes through the usual states
            values: [
                .idle, .playing, .ended,
                .failed(error: TestError.any),
                .idle, .playing, .ended
            ],
            from: player.playbackStatePublisher(),
            during: 4
        ) {
            player.play()
        }
    }
}
