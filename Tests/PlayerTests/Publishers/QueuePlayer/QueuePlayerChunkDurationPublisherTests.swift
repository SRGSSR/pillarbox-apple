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

final class QueuePlayerChunkDurationPublisherTests: TestCase {
    private func chunkDurationPublisher(for player: QueuePlayer) -> AnyPublisher<CMTime, Never> {
        player.contextPublisher()
            .map(\.currentItemContext.chunkDuration)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.invalid, CMTime(value: 1, timescale: 1)],
            from: chunkDurationPublisher(for: player)
        )
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.invalid, CMTime(value: 1, timescale: 1)],
            from: chunkDurationPublisher(for: player)
        ) {
            player.play()
        }
    }

    func testEntirePlaybackInQueuePlayerAdvancingAtItemEnd() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        player.actionAtItemEnd = .advance
        expectAtLeastEqualPublished(
            values: [.invalid, CMTime(value: 1, timescale: 1), .invalid],
            from: chunkDurationPublisher(for: player)
        ) {
            player.play()
        }
    }

    func testEntirePlaybackInQueuePlayerPausingAtItemEnd() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        player.actionAtItemEnd = .pause
        expectAtLeastEqualPublished(
            values: [.invalid, CMTime(value: 1, timescale: 1)],
            from: chunkDurationPublisher(for: player)
        ) {
            player.play()
        }
    }

    func testDuringItemChange() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(items: [item1, item2])
        expectAtLeastEqualPublished(
            values: [
                .invalid,
                CMTime(value: 1, timescale: 1),
                .invalid,
                CMTime(value: 4, timescale: 1)
            ],
            from: chunkDurationPublisher(for: player)
        ) {
            player.play()
        }
    }
}
