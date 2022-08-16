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
    private enum TestError: Error {
        case message1
        case message2
    }

    private var player: Player?

    override func tearDown() {
        super.tearDown()
        player = nil
    }

    func testPlaybackStartPaused() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        player = Player(item: item)
        let states = try awaitPublisher(
            player!.$state
                .collectNext(2)
        )
        expect(states).to(equal([
            .idle,
            .paused
        ], by: areSimilar))
    }

    func testPlaybackStartPlaying() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        player = Player(item: item)
        player!.play()
        let states = try awaitPublisher(
            player!.$state
                .collectNext(2)
        )
        expect(states).to(equal([
            .idle,
            .playing
        ], by: areSimilar))
    }

    func testTogglePlayPause() throws {
        let item = AVPlayerItem(url: TestStreams.validStreamUrl)
        player = Player(item: item)

        player!.play()
        let states1 = try awaitPublisher(
            player!.$state
                .collectNext(2)
        )
        expect(states1).to(equal([
            .idle,
            .playing
        ], by: areSimilar))

        player!.togglePlayPause()
        player!.togglePlayPause()
        let states2 = try awaitPublisher(
            player!.$state
                .collectNext(2)
        )
        expect(states2).to(equal([
            .paused,
            .playing
        ], by: areSimilar))
    }
}
