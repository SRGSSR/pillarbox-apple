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
        expectPublished(values: [.idle], from: player.playbackStatePublisher(), during: 2)
    }

    func testNoPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(values: [.idle, .paused], from: player.playbackStatePublisher(), during: 2)
    }

    func testPlayback() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(values: [.idle, .playing], from: player.playbackStatePublisher(), during: 2) {
            player.play()
        }
    }

    func testPlayPause() {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(values: [.idle, .playing], from: player.playbackStatePublisher()) {
            player.play()
        }
        expectPublishedNext(values: [.paused], from: player.playbackStatePublisher(), during: 2) {
            player.pause()
        }
    }

    func testEntirePlayback() {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.idle, .playing, .ended],
            from: player.playbackStatePublisher(),
            during: 2
        ) {
            player.play()
        }
    }

    func testPlaybackFailure() {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        expectPublished(
            values: [.idle, .failed(error: TestError.any)],
            from: player.playbackStatePublisher(),
            during: 2
        )
    }
}
