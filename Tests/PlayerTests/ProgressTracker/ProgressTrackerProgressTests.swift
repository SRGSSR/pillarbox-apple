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

final class ProgressTrackerProgressTests: TestCase {
    func testUnbound() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectAtLeastEqualPublished(
            values: [0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates()
        )
    }

    func testEmptyPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectAtLeastEqualPublished(
            values: [0],
            from: progressTracker.changePublisher(at: \.progress)
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
            values: [0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates()
        ) {
            progressTracker.player = player
        }
    }

    func testEntirePlayback() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.shortOnDemand.url)
        let player = Player(item: item)
        expectPublished(
            values: [0, 0.25, 0.5, 0.75, 1, 0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            to: beClose(within: 0.1),
            during: .seconds(2)
        ) {
            progressTracker.player = player
            player.play()
        }
    }

    func testPausedDvrStream() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.dvr.url)
        let player = Player(item: item)
        expectAtLeastPublished(
            values: [0, 1, 0.95, 0.9, 0.85, 0.8],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            to: beClose(within: 0.1)
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
        expect(progressTracker.progress).toEventuallyNot(equal(0))

        let progress = progressTracker.progress
        expectAtLeastEqualPublished(
            values: [progress, 0],
            from: progressTracker.changePublisher(at: \.progress)
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
        expect(progressTracker.progress).toEventuallyNot(equal(0))

        let progress = progressTracker.progress
        expectAtLeastEqualPublished(
            values: [progress, 0],
            from: progressTracker.changePublisher(at: \.progress)
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

        let progress = Float(20.0 / Stream.onDemand.duration.seconds)
        expectAtLeastPublished(
            values: [0, progress],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            to: beClose(within: 0.1)
        ) {
            progressTracker.player = player
        }
    }
}
