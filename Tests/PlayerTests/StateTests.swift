//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player
import AVFoundation
import XCTest

final class StateTests: XCTestCase {
    func testPlaybackStartPaused() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .paused])
    }

    func testPlaybackStartPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing]) {
            player.play()
        }
    }

    func testPlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
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
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
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
        let item = AVPlayerItem(url: TestStreams.shortStreamUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .playing, .ended]) {
            player.play()
        }
    }

    func testPlaybackFailure() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableStreamUrl)
        let player = Player(item: item)
        try expectPublisher(player.$state, values: [.idle, .failed(error: TestError.any)])
    }

    func testItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortStreamUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortStreamUrl)
        let player = Player(items: [item1, item2])
        try expectPublisher(player.$state, values: [.idle, .playing, .ended, .playing, .ended]) {
            player.play()
        }
    }
}
