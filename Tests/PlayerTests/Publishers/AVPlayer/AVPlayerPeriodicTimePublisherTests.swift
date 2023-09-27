//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Combine
import Nimble
import Streams

final class AVPlayerPeriodicTimePublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectPublished(
            values: [],
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 2)
            ),
            to: beClose(within: 0.5),
            during: .seconds(2)
        )
    }

    func testTimesInEmptyRange() {
        let player = AVPlayer(url: Stream.live.url)
        expect(player.currentItem?.timeRange).toEventuallyNot(equal(.invalid))
        player.play()
        let publisher = Publishers.PeriodicTimePublisher(
            for: player,
            interval: CMTimeMake(value: 1, timescale: 10)
        )

        let times = collectOutput(from: publisher, during: .seconds(2))
        expect(times).to(allPass { $0.isValid })
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.zero],
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 2)
            ),
            to: beClose(within: 0.5),
            during: .seconds(2)
        )
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
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
        ) {
            player.play()
        }
    }

    func testInitialSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [
                CMTimeMake(value: 5, timescale: 1)
            ],
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 2)
            ),
            to: beClose(within: 0.5)
        ) {
            player.seek(to: CMTime(value: 5, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }

    func testDeallocation() {
        var player: AVPlayer? = AVPlayer()
        _ = Publishers.PeriodicTimePublisher(
            for: player!,
            interval: CMTime(value: 1, timescale: 1)
        )

        weak var weakPlayer = player
        autoreleasepool {
            player = nil
        }
        expect(weakPlayer).to(beNil())
    }
}
