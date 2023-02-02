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

final class SeekTimePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(
            values: [nil],
            from: player.seekTimePublisher(),
            during: 2
        )
    }

    func testSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time = CMTime(value: 1, timescale: 1)
        expectEqualPublished(
            values: [nil, time, nil],
            from: player.seekTimePublisher(),
            during: 2
        ) {
            player.seek(to: time)
        }
    }

    func testMultipleSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expectEqualPublished(
            values: [nil, time1, nil, time2, nil],
            from: player.seekTimePublisher(),
            during: 2
        ) {
            player.seek(to: time1)
            player.seek(to: time2)
        }
    }

    func testMultipleSeeksWithinTimeRange() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        player.play()
        expect(item.timeRange).toEventuallyNot(beNil())

        let time1 = CMTime(value: 1, timescale: 1)
        let time2 = CMTime(value: 2, timescale: 1)
        expectEqualPublished(
            values: [nil, time1, time2, nil],
            from: player.seekTimePublisher(),
            during: 2
        ) {
            player.seek(to: time1)
            player.seek(to: time2)
        }
    }
}
