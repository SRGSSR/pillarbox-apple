//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import Streams
import XCTest

final class AVPlayerItemStatePublisherTests: TestCase {
    func testValidItemStateWithoutPlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay],
            from: item.statePublisher()
        )
    }

    func testValidItemStateWithPlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.unknown, .readyToPlay, .ended],
            from: item.statePublisher()
        ) {
            player.play()
        }
    }

    func testCorruptStream() {
        let item = AVPlayerItem(url: Stream.corruptOnDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [
                .unknown,
                .failed(error: PlayerError.segmentNotFound)
            ],
            from: item.statePublisher()
        )
    }
}
