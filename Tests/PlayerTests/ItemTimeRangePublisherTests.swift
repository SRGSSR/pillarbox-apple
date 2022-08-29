//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemTimeRangePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectPublished(
            values: [],
            from: player.itemTimeRangePublisher(),
            during: 2
        )
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [CMTimeRange(start: .zero, duration: CMTime(value: 120, timescale: 1))],
            from: player.itemTimeRangePublisher(),
            to: beClose(within: 0.5)
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.zero],
            from: player.itemTimeRangePublisher()
        )
    }
}
