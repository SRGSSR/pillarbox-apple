//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import Circumspect
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

        expectAtLeastEqualPublished(values: [.playing, .paused], from: player.$playbackState) {
            progressTracker.isInteracting = true
        }
        expectAtLeastEqualPublishedNext(values: [.playing], from: player.$playbackState) {
            progressTracker.isInteracting = false
        }
    }

    func testInteractionDoesUpdateAlreadyPausedPlayback() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        expect(player.playbackState).toEventually(equal(.paused))

        expectNothingPublishedNext(from: player.$playbackState, during: .seconds(2)) {
            progressTracker.isInteracting = true
        }
        expectNothingPublishedNext(from: player.$playbackState, during: .seconds(2)) {
            progressTracker.isInteracting = false
        }
    }
}
