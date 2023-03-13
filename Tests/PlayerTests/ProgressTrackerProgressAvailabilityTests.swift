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

final class ProgressTrackerProgressAvailabilityTests: TestCase {
    func testUnbound() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectEqualPublished(
            values: [false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates(),
            during: 1
        )
    }

    func testEmptyPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectEqualPublished(
            values: [false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = Player()
        }
    }

    func testPausedPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        expectEqualPublished(
            values: [false, true],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = player
        }
    }

    func testDuringEntirePlayback() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expectEqualPublished(
            values: [false, true, false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates(),
            during: 2
        ) {
            progressTracker.player = player
            player.play()
        }
    }

    func testPausedDvrStream() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expectEqualPublished(
            values: [false, true],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates(),
            during: 5
        ) {
            progressTracker.player = player
        }
    }

    func testRebinding() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.isProgressAvailable).toEventually(beTrue(), timeout: .seconds(2))

        expectEqualPublished(
            values: [true, false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = Player()
        }
    }

    func testUnbinding() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.isProgressAvailable).toEventually(beTrue(), timeout: .seconds(2))

        expectEqualPublished(
            values: [true, false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = nil
        }
    }

    func testBoundToPlayerAtSomeTime() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)

        expect(player.timeRange).toEventuallyNot(equal(.invalid))
        let time = CMTime(value: 20, timescale: 1)

        waitUntil { done in
            player.seek(at(time)) { _ in
                done()
            }
        }

        expectEqualPublished(
            values: [false, true],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = player
        }
    }
}
