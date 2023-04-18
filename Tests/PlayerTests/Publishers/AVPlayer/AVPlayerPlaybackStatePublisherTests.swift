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

final class AVPlayerPlaybackStatePublisherTests: TestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectAtLeastEqualPublished(values: [.idle], from: player.playbackStatePublisher())
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .paused], from: player.playbackStatePublisher())
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .playing], from: player.playbackStatePublisher()) {
            player.play()
        }
    }

    func testPlayPause() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .playing], from: player.playbackStatePublisher()) {
            player.play()
        }
        expectAtLeastEqualPublishedNext(values: [.paused], from: player.playbackStatePublisher()) {
            player.pause()
        }
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(
            values: [.idle, .playing, .ended],
            from: player.playbackStatePublisher()
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
            from: player.playbackStatePublisher()
        )
    }
}
