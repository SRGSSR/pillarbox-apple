//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player
import AVFoundation
import Nimble
import XCTest

final class StateTests: XCTestCase {
    func testPlaybackStartPaused() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        let states = try awaitPublisher(
            player.$state
                .collectNext(2)
        )
        expect(states).to(equal([
            .idle,
            .paused
        ], by: areSimilar))
    }

    func testPlaybackStartPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        player.play()
        let states = try awaitPublisher(
            player.$state
                .collectNext(2)
        )
        expect(states).to(equal([
            .idle,
            .playing
        ], by: areSimilar))
    }

    func testPlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)
        player.play()

        let states1 = try awaitPublisher(
            player.$state
                .collectNext(2)
        )
        expect(states1).to(equal([
            .idle,
            .playing
        ], by: areSimilar))

        player.pause()
        let states2 = try awaitPublisher(
            player.$state
                .collectNext(1)
        )
        expect(states2).to(equal([
            .paused
        ], by: areSimilar))

        player.play()
        let states3 = try awaitPublisher(
            player.$state
                .collectNext(1)
        )
        expect(states3).to(equal([
            .playing
        ], by: areSimilar))
    }

    func testTogglePlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        let player = Player(item: item)

        player.play()
        let states1 = try awaitPublisher(
            player.$state
                .collectNext(2)
        )
        expect(states1).to(equal([
            .idle,
            .playing
        ], by: areSimilar))

        player.togglePlayPause()
        player.togglePlayPause()
        let states2 = try awaitPublisher(
            player.$state
                .collectNext(2)
        )
        expect(states2).to(equal([
            .paused,
            .playing
        ], by: areSimilar))
    }

    func testPlaybackUntilCompletion() throws {
        let item = AVPlayerItem(url: TestStreams.shortStreamUrl)
        let player = Player(item: item)
        player.play()
        let states = try awaitPublisher(
            player.$state
                .collectNext(3)
        )
        expect(states).to(equal([
            .idle,
            .playing,
            .ended
        ], by: areSimilar))
    }

    func testItems() {
        fail()
    }
}
