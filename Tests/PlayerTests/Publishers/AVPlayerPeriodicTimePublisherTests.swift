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

final class AVPlayerPeriodicTimePublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectNothingPublished(
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 10)
            ),
            during: .milliseconds(500)
        )
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [
                .zero,
                CMTimeMake(value: 1, timescale: 10),
                CMTimeMake(value: 2, timescale: 10),
                CMTimeMake(value: 3, timescale: 10)
            ],
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 10)
            ),
            to: beClose(within: 0.1)
        ) {
            player.play()
        }
    }

    func testDeallocation() {
        var player: AVPlayer? = AVPlayer()
        _ = Publishers.PeriodicTimePublisher(
            for: player!,
            interval: CMTime(value: 1, timescale: 1)
        )

        weak let weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }
}
