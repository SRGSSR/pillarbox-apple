//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

@MainActor
final class SingleItemPlaybackStateTests: XCTestCase {
    func testPlaybackStartWithoutPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(values: [.idle, .paused], from: PlaybackState.publisher(for: player), during: 2)
    }

    func testPlaybackStartPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(values: [.idle, .playing], from: PlaybackState.publisher(for: player), during: 2) {
            player.play()
        }
    }

    func testPlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(values: [.idle, .playing], from: PlaybackState.publisher(for: player)) {
            player.play()
        }
        try expectPublishedNext(values: [.paused], from: PlaybackState.publisher(for: player), during: 2) {
            player.pause()
        }
    }

    func testPlaybackUntilCompletion() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(values: [.idle, .playing, .ended], from: PlaybackState.publisher(for: player), during: 2) {
            player.play()
        }
    }

    func testPlaybackFailure() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [.idle, .failed(error: TestError.any)],
            from: PlaybackState.publisher(for: player),
            during: 2
        )
    }

    func testWithoutItems() throws {
        let player = AVPlayer()
        try expectPublished(values: [.idle], from: PlaybackState.publisher(for: player), during: 2)
    }
}

@MainActor
final class MultipleItemPlaybackStateTests: XCTestCase {
    func testChainedShortItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        try expectPublished(
            // The second item can be pre-buffered and is immediately played
            values: [.idle, .playing, .ended, .playing, .ended],
            from: PlaybackState.publisher(for: player),
            during: 3
        ) {
            player.play()
        }
    }

    func testChainedItemsWithFailure() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        try expectPublished(
            // The third item cannot be pre-buffered and goes through the usual states
            values: [
                .idle, .playing, .ended,
                .failed(error: TestError.any),
                .idle, .playing, .ended
            ],
            from: PlaybackState.publisher(for: player),
            during: 3
        ) {
            player.play()
        }
    }
}
