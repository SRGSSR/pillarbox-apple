//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class BufferingPublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(
            values: [false],
            from: player.bufferingPublisher(),
            during: 2
        )
    }

    func testLoaded() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.bufferingPublisher()
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [false, true, false],
            from: player.bufferingPublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.bufferingPublisher()
        )
    }

    func testSeek() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
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
            ) { _ in
            }
        }
    }
}
