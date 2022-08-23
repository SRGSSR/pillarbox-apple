//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import XCTest

final class StateTests: XCTestCase {
    @MainActor
    func testPlaybackStartPaused() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .paused])
    }

    @MainActor
    func testPlaybackStartPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing]) {
            player.play()
        }
    }

    @MainActor
    func testPlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing]) {
            player.play()
        }
        try expectPublisher(player.$state, values: [.paused]) {
            player.pause()
        }
        try expectPublisher(player.$state, values: [.playing]) {
            player.play()
        }
    }

    @MainActor
    func testTogglePlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing]) {
            player.play()
        }
        try expectPublisher(player.$state, values: [.paused, .playing]) {
            player.togglePlayPause()
            player.togglePlayPause()
        }
    }

    @MainActor
    func testPlaybackUntilCompletion() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing, .ended]) {
            player.play()
        }
    }

    @MainActor
    func testPlaybackFailure() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .failed(error: TestError.any)])
    }

    @MainActor
    func testPlaybackWithItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = Player(items: [item1, item2])
        try expectPublisher(player.$state, values: [.idle, .playing, .ended, .playing, .ended]) {
            player.play()
        }
    }

    @MainActor
    func testWithoutPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .paused], during: 3)
    }

    @MainActor
    func testWithoutItems() throws {
        let player = Player()
        try expectPublisher(player.$state, values: [.idle], during: 3)
    }

    // TODO:
    //  - Append item after calling play
    //  - etc.
}
