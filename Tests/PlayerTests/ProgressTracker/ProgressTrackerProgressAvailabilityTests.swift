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

final class ProgressTrackerProgressAvailabilityTests: TestCase {
    func testUnbound() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectAtLeastEqualPublished(
            values: [false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        )
    }

    func testEmptyPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectAtLeastEqualPublished(
            values: [false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        ) {
            progressTracker.player = Player()
        }
    }

    func testPausedPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [false, true],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        ) {
            progressTracker.player = player
        }
    }

    func testEntirePlayback() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [false, true, false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        ) {
            progressTracker.player = player
            player.play()
        }
    }

    func testPausedDvrStream() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expectAtLeastEqualPublished(
            values: [false, true],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        ) {
            progressTracker.player = player
        }
    }

    @MainActor
    func testPlayerChange() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        await expect(progressTracker.isProgressAvailable).toEventually(beTrue())

        expectAtLeastEqualPublished(
            values: [true, false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        ) {
            progressTracker.player = Player()
        }
    }

    @MainActor
    func testPlayerSetToNil() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        await expect(progressTracker.isProgressAvailable).toEventually(beTrue())

        expectAtLeastEqualPublished(
            values: [true, false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        ) {
            progressTracker.player = nil
        }
    }

    @MainActor
    func testBoundToPlayerAtSomeTime() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)

        await expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        let time = CMTime(value: 20, timescale: 1)

        await waitUntil { done in
            player.seek(at(time)) { _ in
                done()
            }
        }

        expectAtLeastEqualPublished(
            values: [false, true],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        ) {
            progressTracker.player = player
        }
    }
}
