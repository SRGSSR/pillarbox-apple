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
        expectAtLeastPublished(
            values: [0, 0.25, 0.5, 0.75, 1, 0],
            from: progressTracker.changePublisher(at: \.progress)
                .removeDuplicates(),
            to: beClose(within: 0.1)
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

    @MainActor
    func testPlayerChange() async {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)
        progressTracker.player = player
        player.play()
        await expect(progressTracker.progress).toEventuallyNot(equal(0))

        let progress = progressTracker.progress
        expectAtLeastEqualPublished(
            values: [progress, 0],
            from: progressTracker.changePublisher(at: \.progress)
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
        await expect(progressTracker.progress).toEventuallyNot(equal(0))

        let progress = progressTracker.progress
        expectAtLeastEqualPublished(
            values: [progress, 0],
            from: progressTracker.changePublisher(at: \.progress)
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

    func testProgressForTimeInTimeRange() {
        let timeRange = CMTimeRange(start: .zero, end: .init(value: 10, timescale: 1))
        expect(ProgressTracker.progress(for: .init(value: 5, timescale: 1), in: timeRange)).to(equal(0.5))
        expect(ProgressTracker.progress(for: .init(value: 15, timescale: 1), in: timeRange)).to(equal(1.5))
    }

    func testValidProgressInRange() {
        expect(ProgressTracker.validProgress(nil, in: 0...1)).to(equal(0))
        expect(ProgressTracker.validProgress(0.5, in: 0...1)).to(equal(0.5))
        expect(ProgressTracker.validProgress(1.5, in: 0...1)).to(equal(1))
    }

    func testTimeForProgressInTimeRange() {
        let timeRange = CMTimeRange(start: .zero, end: .init(value: 10, timescale: 1))
        expect(ProgressTracker.time(forProgress: 0.5, in: timeRange)).to(equal(CMTime(value: 5, timescale: 1)))
        expect(ProgressTracker.time(forProgress: 1.5, in: timeRange)).to(equal(CMTime(value: 15, timescale: 1)))
    }
}
