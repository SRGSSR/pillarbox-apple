//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import Combine
import CoreMedia
import Nimble
import PillarboxCircumspect
import PillarboxStreams

final class ProgressTrackerSeekBehaviorTests: TestCase {
    private func isSeekingPublisher(for player: Player) -> AnyPublisher<Bool, Never> {
        player.propertiesPublisher
            .slice(at: \.isSeeking)
            .eraseToAnyPublisher()
    }

    func testImmediateSeek() {
        let progressTracker = ProgressTracker(
            interval: CMTime(value: 1, timescale: 4),
            seekBehavior: .optimal
        )
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        expect(progressTracker.range).toEventually(equal(0...1))

        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: isSeekingPublisher(for: player)
        ) {
            progressTracker.isInteracting = true
            progressTracker.progress = 0.5
        }
        expect(progressTracker.progress).to(equal(0.5))
    }

    func testDeferredSeek() {
        let progressTracker = ProgressTracker(
            interval: CMTime(value: 1, timescale: 4),
            seekBehavior: .deferred
        )
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        expect(progressTracker.range).toEventually(equal(0...1))

        expectAtLeastEqualPublished(
            values: [false],
            from: isSeekingPublisher(for: player)
        ) {
            progressTracker.isInteracting = true
            progressTracker.progress = 0.5
        }

        expectAtLeastEqualPublishedNext(
            values: [true, false],
            from: isSeekingPublisher(for: player)
        ) {
            progressTracker.isInteracting = false
        }
        expect(progressTracker.progress).toEventually(equal(0.5))
    }
}
