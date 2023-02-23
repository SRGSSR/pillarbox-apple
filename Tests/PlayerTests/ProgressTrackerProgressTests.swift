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
import XCTest

final class ProgressTrackerProgressTests: XCTestCase {
    func testForUnboundTracker() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectEqualPublished(
            values: [0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            during: 1
        )
    }

    func testForTrackerBoundToEmptyPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectEqualPublished(
            values: [0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = Player()
        }
    }

    func testForTrackerBoundToPausedPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expectEqualPublished(
            values: [0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = player
        }
    }

    func testForTrackerDuringEntirePlayback() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expectPublished(
            values: [0, 0.25, 0.5, 0.75, 1, 0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            to: beClose(within: 0.1),
            during: 2
        ) {
            progressTracker.player = player
            player.play()
        }
    }

    func testForTrackerForPausedDvrStream() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expectPublished(
            values: [0, 1, 0.95, 0.9, 0.85, 0.8],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            to: beClose(within: 0.1),
            during: 5
        ) {
            progressTracker.player = player
        }
    }

    func testForTrackerRebinding() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.progress).toEventuallyNot(equal(0), timeout: .seconds(2))

        let progress = progressTracker.progress
        expectEqualPublished(
            values: [progress, 0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = Player()
        }
    }

    func testForTrackerUnbinding() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.progress).toEventuallyNot(equal(0), timeout: .seconds(2))

        let progress = progressTracker.progress
        expectEqualPublished(
            values: [progress, 0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = nil
        }
    }

    func testForTrackerBoundToPlayerAtSomeTime() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)

        expect(player.timeRange).toEventuallyNot(equal(.invalid))
        let time = CMTime(value: 20, timescale: 1)

        waitUntil { done in
            player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { _ in
                done()
            }
        }

        let progress = Float(20.0 / Stream.onDemand.duration.seconds)
        expectPublished(
            values: [0, progress],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            to: beClose(within: 0.1),
            during: 1
        ) {
            progressTracker.player = player
        }
    }
}
