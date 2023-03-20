//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class AVPlayerItemBufferingPublisherTests: TestCase {
    func testLoaded() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: item.bufferingPublisher()
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: item.bufferingPublisher()
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        _ = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: item.bufferingPublisher()
        )
    }

    func testSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: item.bufferingPublisher()
        ) {
            player.play()
        }
        expectAtLeastEqualPublishedNext(
            values: [true, false],
            from: item.bufferingPublisher()
        ) {
            player.seek(
                to: CMTime(value: 10, timescale: 1),
                toleranceBefore: .zero,
                toleranceAfter: .zero
            ) { _ in }
        }
    }
}
