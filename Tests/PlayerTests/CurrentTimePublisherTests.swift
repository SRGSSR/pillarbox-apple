//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class CurrentTimePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectNothingPublished(
            from: player.currentTimePublisher(interval: CMTime(value: 1, timescale: 1)),
            during: 2
        ) {
            player.play()
        }
    }

    func testPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [
                .zero,
                CMTime(value: 1, timescale: 1),
                CMTime(value: 2, timescale: 1),
                CMTime(value: 3, timescale: 1)
            ],
            from: player.currentTimePublisher(interval: CMTime(value: 1, timescale: 1)),
            to: beClose(within: 0.5),
            during: 4
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.zero],
            from: player.currentTimePublisher(interval: CMTime(value: 1, timescale: 1)),
            during: 2
        ) {
            player.play()
        }
    }
}
