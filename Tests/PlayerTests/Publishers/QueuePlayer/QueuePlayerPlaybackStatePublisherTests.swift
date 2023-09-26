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

final class QueuePlayerPlaybackStatePublisherTests: TestCase {
    private func playbackStatePublisher(for player: QueuePlayer) -> AnyPublisher<PlaybackState, Never> {
        player.propertiesPublisher()
            .map(\.playbackState)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = QueuePlayer()
        expectAtLeastEqualPublished(values: [.idle], from: playbackStatePublisher(for: player))
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .paused], from: playbackStatePublisher(for: player))
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .playing], from: playbackStatePublisher(for: player)) {
            player.play()
        }
    }

    func testPlayPause() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .playing], from: playbackStatePublisher(for: player)) {
            player.play()
        }
        expectAtLeastEqualPublishedNext(values: [.paused], from: playbackStatePublisher(for: player)) {
            player.pause()
        }
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.idle, .playing, .ended],
            from: playbackStatePublisher(for: player)
        ) {
            player.play()
        }
    }

    func testPlaybackFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = QueuePlayer(playerItem: item)
        expectEqualPublished(
            values: [.idle],
            from: playbackStatePublisher(for: player),
            during: .seconds(1)
        )
    }

    func testItems() {
        let item1 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let item2 = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = QueuePlayer(items: [item1, item2])
        expectAtLeastEqualPublished(
            // The second item can be pre-buffered and is immediately played
            values: [.idle, .playing, .ended, .playing, .ended],
            from: playbackStatePublisher(for: player)
        ) {
            player.play()
        }
    }
}
