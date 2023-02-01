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

final class NowPlayingInfoCurrentTimePublisherTests: XCTestCase {
    func testEmpty() {
        let player = QueuePlayer()
        expectNothingPublished(
            from: player.nowPlayingInfoCurrentTimePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main),
            during: 2
        )
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectPublished(
            values: [.zero, CMTime(value: 1, timescale: 2), CMTime(value: 1, timescale: 1)],
            from: player.nowPlayingInfoCurrentTimePublisher(interval: CMTime(value: 1, timescale: 2), queue: .main),
            to: beClose(within: 0.1),
            during: 2
        ) {
            player.play()
        }
    }

    func testInitialSeek() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let publisher = player.nowPlayingInfoCurrentTimePublisher(interval: CMTime(value: 1, timescale: 1000), queue: .main)
        let times = collectOutput(from: publisher, during: 3) {
            player.seek(to: CMTime(value: 5, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { _ in })
        }
        expect(times.contains(CMTime(value: 5, timescale: 1))).to(beTrue())
    }

    func testSeekDuringPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        let publisher = player.nowPlayingInfoCurrentTimePublisher(interval: CMTime(value: 1, timescale: 1000), queue: .main)
        expectAtLeastPublished(
            values: [.zero, CMTime(value: 1, timescale: 1000)],
            from: publisher,
            to: beClose(within: 0.3)
        ) {
            player.play()
        }
        let times = collectOutput(from: publisher, during: 3) {
            player.seek(to: CMTime(value: 5, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { _ in })
        }
        expect(times.contains(CMTime(value: 5, timescale: 1))).to(beTrue())
        expect(times.sorted()).to(equal(times))
    }
}
