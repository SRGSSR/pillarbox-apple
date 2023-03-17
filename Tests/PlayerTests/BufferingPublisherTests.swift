//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class BufferingPublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [false],
            from: player.bufferingPublisher()
        )
    }

    func testLoaded() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.bufferingPublisher()
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.bufferingPublisher()
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.bufferingPublisher()
        )
    }

    func testSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.bufferingPublisher()
        ) {
            player.play()
        }
        expectAtLeastEqualPublishedNext(
            values: [true, false],
            from: player.bufferingPublisher()
        ) {
            player.seek(
                to: CMTime(value: 10, timescale: 1),
                toleranceBefore: .zero,
                toleranceAfter: .zero
            ) { _ in }
        }
    }
}
