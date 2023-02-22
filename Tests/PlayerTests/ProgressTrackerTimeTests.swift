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

final class ProgressTrackerTimeTests: XCTestCase {
    func testForUnboundTracker() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectEqualPublished(
            values: [nil],
            from: progressTracker.changePublisher(at: \.time)
                .removeDuplicates(),
            during: 1
        )
    }

    func testForTrackerBoundToEmptyPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectEqualPublished(
            values: [nil],
            from: progressTracker.changePublisher(at: \.time)
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
            values: [nil, .zero],
            from: progressTracker.changePublisher(at: \.time)
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
            values: [
                nil,
                .zero,
                CMTime(value: 1, timescale: 4),
                CMTime(value: 1, timescale: 2),
                CMTime(value: 3, timescale: 4),
                CMTime(value: 1, timescale: 1),
                nil
            ],
            from: progressTracker.changePublisher(at: \.time)
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
            values: [
                nil,
                CMTime(value: 17, timescale: 1),
                CMTime(value: 17, timescale: 1),
                CMTime(value: 17, timescale: 1),
                CMTime(value: 17, timescale: 1),
                CMTime(value: 17, timescale: 1)
            ],
            from: progressTracker.changePublisher(at: \.time)
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
        expect(progressTracker.time).toEventuallyNot(beNil(), timeout: .seconds(2))

        let time = progressTracker.time
        expectEqualPublished(
            values: [time, nil],
            from: progressTracker.changePublisher(at: \.time)
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
        expect(progressTracker.time).toEventuallyNot(beNil(), timeout: .seconds(2))

        let time = progressTracker.time
        expectEqualPublished(
            values: [time, nil],
            from: progressTracker.changePublisher(at: \.time)
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

        expectPublished(
            values: [nil, time],
            from: progressTracker.changePublisher(at: \.time)
                .removeDuplicates(),
            to: beClose(within: 0.1),
            during: 1
        ) {
            progressTracker.player = player
        }
    }
}
