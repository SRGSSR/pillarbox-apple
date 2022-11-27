//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import UserInterface

import Circumspect
import Combine
import CoreMedia
import Nimble
import Player
import XCTest

@MainActor
final class ProgressTrackerTests: XCTestCase {
    func testProgressForUnboundTracker() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectEqualPublished(
            values: [0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            during: 1
        )
    }

    func testRangeForUnboundTracker() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectEqualPublished(
            values: [0...0],
            from: progressTracker.changePublisher(at: \.range)
                .removeDuplicates(),
            during: 1
        )
    }

    func testProgressForTrackerBoundToEmptyPlayer() {
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

    func testRangeForTrackerBoundToEmptyPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectEqualPublished(
            values: [0...0],
            from: progressTracker.changePublisher(at: \.range)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = Player()
        }
    }

    func testProgressForTrackerBoundToPausedPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!)
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

    func testRangeForTrackerBoundToPausedPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!)
        let player = Player(item: item)
        expectEqualPublished(
            values: [0...0, 0...1],
            from: progressTracker.changePublisher(at: \.range)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = player
        }
    }

    func testProgressForTrackerDuringEntirePlayback() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand_short/master.m3u8")!)
        let player = Player(item: item)
        expectPublished(
            values: [0, 0.25, 0.5, 0.75, 1, 0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            to: { lhs, rhs in
                fabsf(lhs - rhs) <= 0.1
            },
            during: 2
        ) {
            progressTracker.player = player
            player.play()
        }
    }

    func testRangeForTrackerDuringEntirePlayback() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand_short/master.m3u8")!)
        let player = Player(item: item)
        expectEqualPublished(
            values: [0...0, 0...1, 0...0],
            from: progressTracker.changePublisher(at: \.range)
                .removeDuplicates(),
            during: 2
        ) {
            progressTracker.player = player
            player.play()
        }
    }

    func testProgressForTrackerImmediateSeekBehavior() {
        let progressTracker = ProgressTracker(
            interval: CMTime(value: 1, timescale: 4),
            seekBehavior: .immediate
        )
        let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!)
        let player = Player(item: item)
        progressTracker.player = player
        expect(progressTracker.range).toEventually(equal(0...1))

        expectEqualPublished(
            values: [false, true, false],
            from: player.$isSeeking,
            during: 2
        ) {
            progressTracker.isInteracting = true
            progressTracker.progress = 0.5
        }
        expect(progressTracker.progress).to(equal(0.5))
    }

    func testProgressForTrackerDeferredSeekBehavior() {
        func testTrackerImmediateSeekBehavior() {
            let progressTracker = ProgressTracker(
                interval: CMTime(value: 1, timescale: 4),
                seekBehavior: .deferred
            )
            let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!)
            let player = Player(item: item)
            progressTracker.player = player
            expect(progressTracker.range).toEventually(equal(0...1))

            expectEqualPublished(
                values: [false],
                from: player.$isSeeking,
                during: 2
            ) {
                progressTracker.isInteracting = true
                progressTracker.progress = 0.5
            }

            expectEqualPublishedNext(
                values: [true, false],
                from: player.$isSeeking,
                during: 2
            ) {
                progressTracker.isInteracting = false
            }
            expect(progressTracker.progress).to(equal(0.5))
        }
    }

    func testProgressForTrackerRebinding() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.progress).toEventuallyNot(equal(0))

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

    func testProgressForTrackerUnbinding() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.progress).toEventuallyNot(equal(0))

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

    func testRangeForTrackerRebinding() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.progress).toEventuallyNot(equal(0))

        expectEqualPublished(
            values: [0...1, 0...0],
            from: progressTracker.changePublisher(at: \.range)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = Player()
        }
    }

    func testRangeForTrackerUnbinding() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem(url: URL(string: "http://localhost:8123/on_demand/master.m3u8")!)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        expect(progressTracker.progress).toEventuallyNot(equal(0))

        expectEqualPublished(
            values: [0...1, 0...0],
            from: progressTracker.changePublisher(at: \.range)
                .removeDuplicates(),
            during: 1
        ) {
            progressTracker.player = nil
        }
    }
}
