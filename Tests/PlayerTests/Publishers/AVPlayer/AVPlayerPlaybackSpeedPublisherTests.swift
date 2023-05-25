//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import Streams
import XCTest

final class AVPlayerPlaybackSpeedPublisherTests: TestCase {
    func testOnDemand() {
        let player = AVPlayer(url: Stream.onDemand.url)
        expectAtLeastEqualPublished(values: [2], from: player.playbackSpeedPublisher()) {
            player.rate = 2
        }
    }

    func testMinSpeedOnDemand() {
        let player = AVPlayer(url: Stream.onDemand.url)
        expectNothingPublished(from: player.playbackSpeedPublisher(), during: .seconds(1)) {
            player.rate = 0
        }
    }

    func testMaxSpeedOnDemand() {
        let player = AVPlayer(url: Stream.onDemand.url)
        expectAtLeastEqualPublished(values: [2], from: player.playbackSpeedPublisher()) {
            player.rate = 3
        }
    }

    func testMinSpeedLive() {
        let player = AVPlayer(url: Stream.live.url)
        expectNothingPublished(from: player.playbackSpeedPublisher(), during: .seconds(1)) {
            player.rate = 0
        }
    }

    func testMaxSpeedLive() {
        let player = AVPlayer(url: Stream.live.url)
        expectEqualPublished(values: [1], from: player.playbackSpeedPublisher(), during: .seconds(1)) {
            player.rate = 3
        }
    }


    func testDvr() {
        let player = AVPlayer(url: Stream.dvr.url)
        expectEqualPublished(values: [1], from: player.playbackSpeedPublisher(), during: .seconds(1)) {
            player.rate = 2
        }
    }

    func testMinSpeedDvr() {
        let player = AVPlayer(url: Stream.dvr.url)
        expectAtLeastEqualPublished(values: [0.1], from: player.playbackSpeedPublisher()) {
            player.rate = 0.1
        }
    }

    func testMaxSpeedDvr() {
        let player = AVPlayer(url: Stream.dvr.url)
        expectEqualPublished(values: [1], from: player.playbackSpeedPublisher(), during: .seconds(1)) {
            player.rate = 3
        }
    }

    func testMaxSpeedDvrInThePast() {
        let player = AVPlayer(url: Stream.dvr.url)

        waitUntil { done in
            player.seek(to: .init(value: 1, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                done()
            }
        }

        expectAtLeastEqualPublished(values: [2], from: player.playbackSpeedPublisher()) {
            player.rate = 3
        }
    }
}
