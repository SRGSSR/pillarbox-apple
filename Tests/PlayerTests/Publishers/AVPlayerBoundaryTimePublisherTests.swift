//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import AVFoundation
import Combine
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class AVPlayerBoundaryTimePublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectNothingPublished(
            from: Publishers.BoundaryTimePublisher(
                for: player,
                times: [CMTimeMake(value: 1, timescale: 2)]
            ),
            during: .seconds(2)
        )
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectNothingPublished(
            from: Publishers.BoundaryTimePublisher(
                for: player,
                times: [CMTimeMake(value: 1, timescale: 2)]
            ),
            during: .seconds(2)
        )
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [
                "tick", "tick"
            ],
            from: Publishers.BoundaryTimePublisher(
                for: player,
                times: [
                    CMTimeMake(value: 1, timescale: 2),
                    CMTimeMake(value: 2, timescale: 2)
                ]
            )
            .map { "tick" }
        ) {
            player.play()
        }
    }

    func testDeallocation() {
        var player: AVPlayer? = AVPlayer()
        _ = Publishers.BoundaryTimePublisher(
            for: player!,
            times: [
                CMTimeMake(value: 1, timescale: 2)
            ]
        )

        weak let weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }
}
