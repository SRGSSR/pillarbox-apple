//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class ItemTimeRangePublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(
            values: [.invalid],
            from: player.currentItemTimeRangePublisher()
        )
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [.invalid, CMTimeRange(start: .zero, duration: Stream.onDemand.duration)],
            from: player.currentItemTimeRangePublisher(),
            to: beClose(within: 1)
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: Stream.live.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.invalid, .zero],
            from: player.currentItemTimeRangePublisher()
        )
    }

    func testQueueExhaustion() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        player.actionAtItemEnd = .advance
        expectAtLeastEqualPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration),
                .invalid
            ],
            from: player.currentItemTimeRangePublisher()
        ) {
            player.play()
        }
    }

    func testQueueEnd() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVQueuePlayer(playerItem: item)
        player.actionAtItemEnd = .none
        expectAtLeastEqualPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration)
            ],
            from: player.currentItemTimeRangePublisher()
        ) {
            player.play()
        }
    }

    func testWithoutAutomaticallyLoadedAssetKeys() {
        let asset = AVURLAsset(url: Stream.onDemand.url)
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: [])
        let player = AVPlayer(playerItem: item)
        expectAtLeastPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.onDemand.duration)
            ],
            from: player.currentItemTimeRangePublisher(),
            to: beClose(within: 1)
        )
    }
}
