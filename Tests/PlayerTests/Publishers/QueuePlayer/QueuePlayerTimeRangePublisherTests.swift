//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Combine
import Streams
import XCTest

// swiftlint:disable:next type_name
final class AVPlayerCurrentItemTimeRangePublisherTests: TestCase {
    private func seekableTimeRangePublisher(for player: QueuePlayer) -> AnyPublisher<CMTimeRange, Never> {
        player.timeContextPublisher()
            .map(\.seekableTimeRange)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(
            values: [.invalid],
            from: seekableTimeRangePublisher(for: player)
        )
    }

    func testOnDemand() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastPublished(
            values: [.invalid, CMTimeRange(start: .zero, duration: Stream.onDemand.duration)],
            from: seekableTimeRangePublisher(for: player),
            to: beClose(within: 1)
        )
    }

    func testLive() {
        let item = AVPlayerItem(url: Stream.live.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.invalid, .zero],
            from: seekableTimeRangePublisher(for: player)
        )
    }

    func testQueueExhaustion() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        player.actionAtItemEnd = .advance
        expectAtLeastEqualPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration),
                .invalid
            ],
            from: seekableTimeRangePublisher(for: player)
        ) {
            player.play()
        }
    }

    func testQueueEnd() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        player.actionAtItemEnd = .none
        expectAtLeastEqualPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.shortOnDemand.duration)
            ],
            from: seekableTimeRangePublisher(for: player)
        ) {
            player.play()
        }
    }

    func testWithoutAutomaticallyLoadedAssetKeys() {
        let asset = AVURLAsset(url: Stream.onDemand.url)
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: [])
        let player = QueuePlayer(playerItem: item)
        expectAtLeastPublished(
            values: [
                .invalid,
                CMTimeRange(start: .zero, duration: Stream.onDemand.duration)
            ],
            from: seekableTimeRangePublisher(for: player),
            to: beClose(within: 1)
        )
    }
}
