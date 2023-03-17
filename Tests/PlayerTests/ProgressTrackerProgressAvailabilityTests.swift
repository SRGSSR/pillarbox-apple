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

    func testDuringEntirePlayback() {
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

    func testPlayerChange() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.isProgressAvailable).toEventually(beTrue())

        expectAtLeastEqualPublished(
            values: [true, false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        ) {
            progressTracker.player = Player()
        }
    }

    func testPlayerSetToNil() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.isProgressAvailable).toEventually(beTrue())

        expectAtLeastEqualPublished(
            values: [true, false],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
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

        expectAtLeastEqualPublished(
            values: [false, true],
            from: progressTracker.changePublisher(at: \.isProgressAvailable)
                .removeDuplicates()
        ) {
            progressTracker.player = player
        }
    }
}
