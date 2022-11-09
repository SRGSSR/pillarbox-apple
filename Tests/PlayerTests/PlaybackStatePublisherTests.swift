//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import XCTest

final class PlaybackStatePublisherTests: XCTestCase {
    func testEmpty() {
        let player = AVPlayer()
        expectEqualPublished(values: [.idle], from: player.playbackStatePublisher(), during: 2)
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(values: [.idle, .paused], from: player.playbackStatePublisher(), during: 2)
    }

    func testPlayback() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(values: [.idle, .playing], from: player.playbackStatePublisher(), during: 2) {
            player.play()
        }
    }

    func testPlayPause() {
        let item = AVPlayerItem(url: Stream.onDemand.url)
        let player = AVPlayer(playerItem: item)
        expectAtLeastEqualPublished(values: [.idle, .playing], from: player.playbackStatePublisher()) {
            player.play()
        }
        expectEqualPublishedNext(values: [.paused], from: player.playbackStatePublisher(), during: 2) {
            player.pause()
        }
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: Stream.shortOnDemand.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [.idle, .playing, .ended],
            from: player.playbackStatePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testPlaybackFailure() {
        let item = AVPlayerItem(url: Stream.unavailable.url)
        let player = AVPlayer(playerItem: item)
        expectEqualPublished(
            values: [
                .idle,
                .failed(error: PlayerError.resourceNotFound)
            ],
            from: player.playbackStatePublisher(),
            during: 2
        )
    }
}
