//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

final class SeekingPublisherTests: TestCase {
    func testEmpty() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(
            values: [false],
            from: player.seekingPublisher()
        )
    }

    func testSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.seekingPublisher()
        ) {
            player.seek(to: time)
        }
    }

    func testMultipleSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expectAtLeastEqualPublished(
            values: [false, true, false, true, false],
            from: player.seekingPublisher()
        ) {
            player.seek(to: time1)
            player.seek(to: time2)
        }
    }

    func testMultipleSeeksWithinTimeRange() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        player.play()
        expect(item.timeRange).toEventuallyNot(equal(.invalid))

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: player.seekingPublisher()
        ) {
            player.seek(to: time1)
            player.seek(to: time2)
        }
    }

    func testTargetSeekTimeWithMultipleSeeks() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expect(player.timeRange).toEventuallyNot(equal(.invalid))

        let time1 = CMTime(value: 1, timescale: 1)
        player.seek(to: time1)
        expect(player.targetSeekTime).to(equal(time1))

        let time2 = CMTime(value: 2, timescale: 1)
        player.seek(to: time2)
        expect(player.targetSeekTime).to(equal(time2))
    }
}
