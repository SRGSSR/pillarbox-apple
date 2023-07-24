//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Combine
import CoreMedia
import Nimble
import Streams
import XCTest

final class ProgressTrackerPlaybackStateTests: TestCase {
    func testInteractionPausesPlayback() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(player.playbackState).toEventually(equal(.playing))

        progressTracker.isInteracting = true
        expect(player.playbackState).toEventually(equal(.paused))

        progressTracker.isInteracting = false
        expect(player.playbackState).toEventually(equal(.playing))
    }

    func testInteractionDoesUpdateAlreadyPausedPlayback() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))

        progressTracker.isInteracting = true
        expect(player.playbackState).toAlways(equal(.paused), until: .seconds(1))

        progressTracker.isInteracting = false
        expect(player.playbackState).toAlways(equal(.paused), until: .seconds(1))
    }

    func testTransferInteractionBetweenPlayers() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))

        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let player1 = Player(item: item1)
        progressTracker.player = player1
        player1.play()
        expect(player1.playbackState).toEventually(equal(.playing))

        progressTracker.isInteracting = true
        expect(player1.playbackState).toEventually(equal(.paused))

        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player2 = Player(item: item2)
        progressTracker.player = player2
        player2.play()
        expect(player2.playbackState).toEventually(equal(.playing))

        progressTracker.player = player2
        expect(player1.playbackState).toEventually(equal(.playing))
        expect(player2.playbackState).toEventually(equal(.paused))
    }
}
