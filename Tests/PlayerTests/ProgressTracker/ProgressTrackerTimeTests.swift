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

final class ProgressTrackerTimeTests: TestCase {
    func testUnbound() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectAtLeastEqualPublished(
            values: [.invalid],
            from: progressTracker.changePublisher(at: \.time)
                .removeDuplicates()
        )
    }

    func testEmptyPlayer() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        expectAtLeastEqualPublished(
            values: [.invalid],
            from: progressTracker.changePublisher(at: \.time)
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
            values: [.invalid, .zero],
            from: progressTracker.changePublisher(at: \.time)
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
            values: [
                .invalid,
                .zero,
                CMTime(value: 1, timescale: 4),
                CMTime(value: 1, timescale: 2),
                CMTime(value: 3, timescale: 4),
                CMTime(value: 1, timescale: 1),
                .invalid
            ],
            from: progressTracker.changePublisher(at: \.time)
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
            values: [
                .invalid,
                CMTime(value: 17, timescale: 1),
                CMTime(value: 17, timescale: 1),
                CMTime(value: 17, timescale: 1),
                CMTime(value: 17, timescale: 1),
                CMTime(value: 17, timescale: 1)
            ],
            from: progressTracker.changePublisher(at: \.time)
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
        expect(progressTracker.time).toEventuallyNot(equal(.invalid))

        let time = progressTracker.time
        expectAtLeastEqualPublished(
            values: [time, .invalid],
            from: progressTracker.changePublisher(at: \.time)
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
        expect(progressTracker.time).toEventuallyNot(equal(.invalid))

        let time = progressTracker.time
        expectAtLeastEqualPublished(
            values: [time, .invalid],
            from: progressTracker.changePublisher(at: \.time)
                .removeDuplicates()
        ) {
            progressTracker.player = nil
        }
    }

    func testBoundToPlayerAtSomeTime() {
        let progressTracker = ProgressTracker(interval: CMTime(value: 1, timescale: 4))
        let item = PlayerItem.simple(url: Stream.onDemand.url)
        let player = Player(item: item)

        expect(player.seekableTimeRange).toEventuallyNot(equal(.invalid))
        let time = CMTime(value: 20, timescale: 1)

        waitUntil { done in
            player.seek(at(time)) { _ in
                done()
            }
        }

        expectAtLeastPublished(
            values: [.invalid, time],
            from: progressTracker.changePublisher(at: \.time)
                .removeDuplicates(),
            to: beClose(within: 0.1)
        ) {
            progressTracker.player = player
        }
    }
}
