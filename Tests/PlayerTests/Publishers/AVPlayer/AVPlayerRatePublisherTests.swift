//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Streams
import XCTest

final class AVPlayerRatePublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [0],
            from: player.ratePublisher()
        )
    }

    func testOnDemand() {
        let player = AVPlayer(url: Stream.onDemand.url)
        expectAtLeastEqualPublished(
            values: [0, 1],
            from: player.ratePublisher()
        ) {
            player.play()
        }
    }

    func testOnDemandLowestRate() {
        let player = AVPlayer(url: Stream.onDemand.url)
        player.rate = -1

        expectAtLeastEqualPublished(
            values: [0],
            from: player.ratePublisher()
        )
    }

    func testOnDemandHighestRate() {
        let player = AVPlayer(url: Stream.onDemand.url)
        player.rate = .infinity

        expectAtLeastEqualPublished(
            values: [2],
            from: player.ratePublisher()
        )
    }

    func testLive() {
        let player = AVPlayer(url: Stream.live.url)
        expectAtLeastEqualPublished(
            values: [0, 1],
            from: player.ratePublisher()
        ) {
            player.play()
        }
    }

    func testLiveLowestRate() {
        let player = AVPlayer(url: Stream.live.url)
        player.rate = -1

        expectAtLeastEqualPublished(
            values: [0],
            from: player.ratePublisher()
        )
    }

    func testLiveHighestRate() {
        let player = AVPlayer(url: Stream.live.url)
        player.rate = .infinity

        expectAtLeastEqualPublished(
            values: [2],
            from: player.ratePublisher()
        )
    }

    func testDvr() {
        let player = AVPlayer(url: Stream.dvr.url)
        expectAtLeastEqualPublished(
            values: [0, 1],
            from: player.ratePublisher()
        ) {
            player.play()
        }
    }

    func testDvrLowestRate() {
        let player = AVPlayer(url: Stream.dvr.url)
        player.rate = -1

        expectAtLeastEqualPublished(
            values: [0],
            from: player.ratePublisher()
        )
    }

    func testDvrHighestRate() {
        let player = AVPlayer(url: Stream.dvr.url)
        player.rate = .infinity

        expectAtLeastEqualPublished(
            values: [2],
            from: player.ratePublisher()
        )
    }
}
