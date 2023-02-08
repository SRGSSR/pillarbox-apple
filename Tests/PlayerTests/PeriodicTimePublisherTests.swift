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
import XCTest

final class PeriodicTimePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectPublished(
            values: [
                .invalid
            ],
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 2)
            ),
            to: beClose(within: 0.5),
            during: 2
        )
    }

    func testTimesStayInRange() {
        let player = AVPlayer(url: Stream.dvr.url)
        expect(player.currentItem?.timeRange).toEventuallyNot(equal(.invalid))
        player.play()
        let publisher = Publishers.CombineLatest(
            Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 10)
            ),
            player.currentItemTimeRangePublisher()
        )

        let times = collectOutput(from: publisher, during: 2)
        expect(times).to(allPass { time, timeRange in
            timeRange.start <= time && time <= timeRange.end
        })
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectPublished(
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
            values: [CMTimeMake(value: 5, timescale: 1)],
            from: Publishers.PeriodicTimePublisher(
                for: player,
                interval: CMTimeMake(value: 1, timescale: 2)
            ),
            to: beClose(within: 0.5)
        ) {
            player.seek(to: CMTime(value: 5, timescale: 1))
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
