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
        try expectPublishedNext(values: [.idle, .paused], from: player.$state)
    }

    func testPlaybackStartPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .playing], from: player.$state) {
            player.play()
        }
    }

    func testPlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .playing], from: player.$state) {
            player.play()
        }
        try expectPublishedNext(values: [.paused], from: player.$state) {
            player.pause()
        }
        try expectPublishedNext(values: [.playing], from: player.$state) {
            player.play()
        }
    }

    func testTogglePlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .playing], from: player.$state) {
            player.play()
        }
        try expectPublishedNext(values: [.paused, .playing], from: player.$state) {
            player.togglePlayPause()
            player.togglePlayPause()
        }
    }

    func testPlaybackUntilCompletion() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .playing, .ended], from: player.$state) {
            player.play()
        }
    }

    func testPlaybackFailure() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .failed(error: TestError.any)], from: player.$state)
    }

    func testPlaybackWithItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = Player(items: [item1, item2])
        try expectPublishedNext(values: [.idle, .playing, .ended, .playing, .ended], from: player.$state) {
            player.play()
        }
    }

    func testWithoutPlayback() throws {
        let item = AVPlayerItem(url: TestStreams.onDemandUrl)
        let player = Player(item: item)
        try expectPublishedNext(values: [.idle, .paused], from: player.$state, during: 3)
    }

    func testWithoutItems() throws {
        let player = Player()
        try expectPublished(values: [.idle], from: player.$state, during: 3)
    }

    // TODO:
    //  - Append item after calling play
    //  - etc.
}
