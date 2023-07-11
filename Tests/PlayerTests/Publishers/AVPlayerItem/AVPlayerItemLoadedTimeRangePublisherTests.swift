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

private class MockAVPlayerItem: AVPlayerItem {
    override var duration: CMTime {
        CMTime(seconds: Double.nan, preferredTimescale: 0)
    }
}

// swiftlint:disable:next type_name
final class AVPlayerItemLoadedTimeRangePublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [.invalid],
            from: player.currentItemLoadedTimeRangePublisher()
        )
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [.invalid, CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration)],
            from: player.currentItemLoadedTimeRangePublisher(),
            to: beClose(within: 1)
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: Stream.live.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.invalid],
            from: player.currentItemLoadedTimeRangePublisher()
        )
    }

    func testQueueExhaustion() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        player.actionAtItemEnd = .advance
        expectAtLeastPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration),
                .invalid
            ],
            from: player.currentItemLoadedTimeRangePublisher(),
            to: beClose(within: 1)
        ) {
            player.play()
        }
    }

    func testQueueEnd() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        player.actionAtItemEnd = .none
        expectAtLeastPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration)
            ],
            from: player.currentItemLoadedTimeRangePublisher(),
            to: beClose(within: 1)
        ) {
            player.play()
        }
    }

    func testWithoutAutomaticallyLoadedAssetKeys() {
        let asset = AVURLAsset(url: Stream.shortOnDemand.url)
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: [])
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration)
            ],
            from: player.currentItemLoadedTimeRangePublisher(),
            to: beClose(within: 1)
        )
    }

    func testNonNumericDuration() {
        let item = MockAVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.invalid],
            from: player.currentItemLoadedTimeRangePublisher(),
            during: .seconds(2)
        )
    }
}
