//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import XCTest

@MainActor
final class StateTests: XCTestCase {
    func testPlaybackStartPaused() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .paused])
    }

    func testPlaybackStartPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing]) {
            player.play()
        }
    }

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

    func testPlaybackUntilCompletion() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing, .ended]) {
            player.play()
        }
    }

    func testPlaybackFailure() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .failed(error: TestError.any)])
    }

    func testPlaybackWithItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = Player(items: [item1, item2])
        try expectPublisher(player.$state, values: [.idle, .playing, .ended, .playing, .ended]) {
            player.play()
        }
    }

    func testWithoutPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .paused], during: 3)
    }

    func testWithoutItems() throws {
        let player = Player()
        try expectPublisher(player.$state, values: [.idle], during: 3)
    }

    // TODO:
    //  - Append item after calling play
    //  - etc.
}
