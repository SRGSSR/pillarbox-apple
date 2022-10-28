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
        expectEqualPublished(
            values: [.invalid],
            from: player.itemTimeRangePublisher(),
            during: 2
        )
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [CMTimeRange(start: .zero, duration: Stream.onDemand.duration)],
            from: player.itemTimeRangePublisher(),
            to: beClose(within: 1)
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: Stream.live.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.zero],
            from: player.itemTimeRangePublisher()
        )
    }

    func testQueueExhaustion() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        player.actionAtItemEnd = .advance
        expectEqualPublished(
            values: [
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration),
                .invalid
            ],
            from: player.itemTimeRangePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testQueueEnd() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        player.actionAtItemEnd = .none
        expectEqualPublished(
            values: [
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration)
            ],
            from: player.itemTimeRangePublisher(),
            during: 2
        ) {
            player.play()
        }
    }
}
