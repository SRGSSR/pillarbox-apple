//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble
import PillarboxStreams

final class ProgressTrackerPlaybackStateTests: TestCase {
    @MainActor
    func testInteractionPausesPlayback() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        await expect(player.playbackState).toEventually(equal(.playing))

        progressTracker.isInteracting = true
        await expect(player.playbackState).toEventually(equal(.paused))

        progressTracker.isInteracting = false
        await expect(player.playbackState).toEventually(equal(.playing))
    }

    @MainActor
    func testInteractionDoesUpdateAlreadyPausedPlayback() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        await expect(player.playbackState).toEventually(equal(.paused))

        progressTracker.isInteracting = true
        await expect(player.playbackState).toAlways(equal(.paused), until: .seconds(1))

        progressTracker.isInteracting = false
        await expect(player.playbackState).toAlways(equal(.paused), until: .seconds(1))
    }

    @MainActor
    func testTransferInteractionBetweenPlayers() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))

        let item1 = PlayerItem.simple(url: Stream.onDemand.url)
        let player1 = Player(item: item1)
        progressTracker.player = player1
        player1.play()
        await expect(player1.playbackState).toEventually(equal(.playing))

        progressTracker.isInteracting = true
        await expect(player1.playbackState).toEventually(equal(.paused))

        let item2 = PlayerItem.simple(url: Stream.onDemand.url)
        let player2 = Player(item: item2)
        progressTracker.player = player2
        player2.play()
        await expect(player2.playbackState).toEventually(equal(.playing))

        progressTracker.player = player2
        await expect(player1.playbackState).toEventually(equal(.playing))
        await expect(player2.playbackState).toEventually(equal(.paused))
    }
}
