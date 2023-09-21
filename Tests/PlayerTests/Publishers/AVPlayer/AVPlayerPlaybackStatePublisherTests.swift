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

final class AVPlayerPlaybackStatePublisherTests: TestCase {
    private func playbackStatePublisher(for player: AVPlayer) -> AnyPublisher<PlaybackState, Never> {
        player.contextPublisher()
            .map(\.playbackState)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(values: [.idle], from: playbackStatePublisher(for: player))
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .paused], from: playbackStatePublisher(for: player))
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .playing], from: playbackStatePublisher(for: player)) {
            player.play()
        }
    }

    func testPlayPause() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .playing], from: playbackStatePublisher(for: player)) {
            player.play()
        }
        expectAtLeastEqualPublishedNext(values: [.paused], from: playbackStatePublisher(for: player)) {
            player.pause()
        }
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.idle, .playing, .ended],
            from: playbackStatePublisher(for: player)
        ) {
            player.play()
        }
    }

    func testPlaybackFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [
                .idle,
                .failed(error: PlayerError.resourceNotFound)
            ],
            from: playbackStatePublisher(for: player)
        )
    }
}
