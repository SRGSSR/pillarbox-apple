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

private class MockAVPlayerItem: AVPlayerItem {
    override var duration: CMTime {
        .init(value: 0, timescale: 0)
    }
}

// swiftlint:disable:next type_name
final class AVPlayerItemLoadedTimeRangePublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [0],
            from: player.currentItemBufferPublisher()
        )
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [0, 1],
            from: player.currentItemBufferPublisher(),
            to: beClose(within: 0.2)
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: Stream.live.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [0],
            from: player.currentItemBufferPublisher()
        )
    }

    func testQueueExhaustion() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        player.actionAtItemEnd = .advance
        expectAtLeastPublished(
            values: [0, 1, 0],
            from: player.currentItemBufferPublisher(),
            to: beClose(within: 0.2)
        ) {
            player.play()
        }
    }

    func testQueueEnd() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        player.actionAtItemEnd = .none
        expectAtLeastPublished(
            values: [0, 1],
            from: player.currentItemBufferPublisher(),
            to: beClose(within: 0.2)
        ) {
            player.play()
        }
    }

    func testWithoutAutomaticallyLoadedAssetKeys() {
        let asset = AVURLAsset(url: Stream.shortOnDemand.url)
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: [])
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [0, 1],
            from: player.currentItemBufferPublisher(),
            to: beClose(within: 0.2)
        )
    }

    func testNonNumericDuration() {
        let item = MockAVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [0],
            from: player.currentItemBufferPublisher(),
            during: .seconds(2)
        )
    }
}
