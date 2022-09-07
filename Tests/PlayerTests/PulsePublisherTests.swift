//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class PulsePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectSimilarPublished(
            values: [],
            from: player.pulsePublisher(configuration: PlayerConfiguration()),
            during: 2
        )
    }

    func testPlayback() {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        let player = AVPlayer(playerItem: item)
        expectAtLeastSimilarPublished(
            values: [
                Pulse(time: .zero, timeRange: .zero, itemDuration: .indefinite),
                Pulse(time: CMTime(value: 1, timescale: 1), timeRange: .zero, itemDuration: .indefinite),
                Pulse(time: CMTime(value: 2, timescale: 1), timeRange: .zero, itemDuration: .indefinite)
            ],
            from: player.pulsePublisher(configuration: PlayerConfiguration())
        ) {
            player.play()
        }
    }

    func testFailure() {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        expectSimilarPublished(
            values: [],
            from: player.pulsePublisher(configuration: PlayerConfiguration()),
            during: 2
        ) {
            player.play()
        }
    }
}
