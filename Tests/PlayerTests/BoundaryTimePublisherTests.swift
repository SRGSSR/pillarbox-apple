//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Combine
import XCTest

final class BoundaryTimePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectNothingPublished(
            from: Publishers.BoundaryTimePublisher(
                for: player,
                times: [CMTimeMake(value: 1, timescale: 2)]
            ),
            during: 2
        )
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectNothingPublished(
            from: Publishers.BoundaryTimePublisher(
                for: player,
                times: [CMTimeMake(value: 1, timescale: 2)]
            ),
            during: 2
        )
    }

    func testPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [
                "tick", "tick"
            ],
            from: Publishers.BoundaryTimePublisher(
                for: player,
                times: [
                    CMTimeMake(value: 1, timescale: 2),
                    CMTimeMake(value: 2, timescale: 2)
                ]
            ).map { "tick" },
            during: 2
        ) {
            player.play()
        }
    }
}
