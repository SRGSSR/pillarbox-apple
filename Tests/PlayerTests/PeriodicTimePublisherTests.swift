//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Combine
import Circumspect
import Nimble
import XCTest

final class PeriodicTimePublisherTests: XCTestCase {
    func testEmpty() throws {
        let player = AVPlayer()
        try expectNothingPublished(
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 2)
            ),
            during: 2
        )
    }

    func testNoPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [
                .zero
            ],
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 2)
            ),
            to: beClose(within: 0.5),
            during: 2
        )
    }

    func testPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        player.play()
        try expectPublished(
            values: [
                .zero,
                CMTimeMake(value: 1, timescale: 2),
                CMTimeMake(value: 2, timescale: 2),
                CMTimeMake(value: 3, timescale: 2),
                CMTimeMake(value: 4, timescale: 2),
                CMTimeMake(value: 5, timescale: 2)
            ],
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 2)
            ),
            to: beClose(within: 0.5)
        )
    }
}
