//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Circumspect
import Nimble
import XCTest

final class PulseTests: XCTestCase {
    func testValid() {
        expect(Pulse(time: .zero, timeRange: .zero)).notTo(beNil())
        expect(Pulse(
            time: CMTime(value: 1, timescale: 1),
            timeRange: .zero
        )).notTo(beNil())
        expect(Pulse(
            time: .zero,
            timeRange: CMTimeRange(
                start: CMTime(value: 1, timescale: 1),
                duration: CMTime(value: 10, timescale: 1)
            )
        )).notTo(beNil())
        expect(Pulse(
            time: CMTime(value: 1, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 1, timescale: 1),
                duration: CMTime(value: 10, timescale: 1)
            )
        )).notTo(beNil())
    }

    func testInvalid() {
        expect(Pulse(time: .invalid, timeRange: .zero)).to(beNil())
        expect(Pulse(time: .indefinite, timeRange: .zero)).to(beNil())
        expect(Pulse(time: .positiveInfinity, timeRange: .zero)).to(beNil())
        expect(Pulse(time: .negativeInfinity, timeRange: .zero)).to(beNil())
        expect(Pulse(time: .zero, timeRange: .invalid)).to(beNil())
    }
}

final class PulseProgressTests: XCTestCase {
    func testProgress() {
        let pulse = Pulse(
            time: CMTime(value: 10, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 0, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )!
        expect(pulse.progress).to(equal(0.5))
    }

    func testProgressBelowLowerBound() {
        let pulse = Pulse(
            time: CMTime(value: 10, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 30, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )!
        expect(pulse.progress).to(equal(0))
    }

    func testProgressAboveUpperBound() {
        let pulse = Pulse(
            time: CMTime(value: 40, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )!
        expect(pulse.progress).to(equal(1))
    }

    func testProgressForEmptyTimeRange() {
        let pulse = Pulse(
            time: CMTime(value: 100, timescale: 1),
            timeRange: .zero
        )!
        expect(pulse.progress).to(equal(0))
    }
}

final class PulseTimeTests: XCTestCase {
    func testTimeForProgress() {
        let pulse = Pulse(
            time: .zero,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 30, timescale: 1)
            )
        )!
        expect(pulse.time(forProgress: 0.5)).to(equal(CMTime(value: 25, timescale: 1)))
    }

    func testTimeForProgressBelowLowerBound() {
        let pulse = Pulse(
            time: .zero,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 30, timescale: 1)
            )
        )!
        expect(pulse.time(forProgress: -1)).to(equal(CMTime(value: 10, timescale: 1)))
    }

    func testTimeForProgressAboveUpperBound() {
        let pulse = Pulse(
            time: .zero,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 30, timescale: 1)
            )
        )!
        expect(pulse.time(forProgress: 2)).to(equal(CMTime(value: 40, timescale: 1)))
    }

    func testTimeForProgressWithEmptyTimeRange() {
        let pulse = Pulse(time: .zero, timeRange: .zero)!
        expect(pulse.time(forProgress: 2)).to(beNil())
    }
}

final class SingleItemPulsePublisherTests: XCTestCase {
    func testOnDemandPulse() throws {
        let item = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                )
            ],
            from: Pulse.publisher(for: player, queue: .main)
        ) {
            player.play()
        }
    }

    func testLivePulse() throws {
        let item = AVPlayerItem(url: TestStreams.liveUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [
                Pulse(time: .zero, timeRange: .zero),
                Pulse(time: CMTime(value: 1, timescale: 1), timeRange: .zero),
                Pulse(time: CMTime(value: 2, timescale: 1), timeRange: .zero)
            ],
            from: Pulse.publisher(for: player, queue: .main)
        ) {
            player.play()
        }
    }

    func testFailedPlaybackPulse() throws {
        let item = AVPlayerItem(url: TestStreams.unavailableUrl)
        let player = AVPlayer(playerItem: item)
        try expectPublished(
            values: [],
            from: Pulse.publisher(for: player, queue: .main),
            during: 2
        ) {
            player.play()
        }
    }

    func testNonPlayingPulse() throws {
        let player = AVPlayer()
        try expectPublished(
            values: [],
            from: Pulse.publisher(for: player, queue: .main),
            during: 2
        ) {
            player.play()
        }
    }
}

final class MultipleItemPulsePublisherTests: XCTestCase {
    func testChainedShortItems() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2])
        try expectPublished(
            values: [
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                ),
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                )
            ],
            from: Pulse.publisher(for: player, queue: .main),
            during: 4
        ) {
            player.play()
        }
    }

    func testChainedItemsWithFailure() throws {
        let item1 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let item2 = AVPlayerItem(url: TestStreams.unavailableUrl)
        let item3 = AVPlayerItem(url: TestStreams.shortOnDemandUrl)
        let player = AVQueuePlayer(items: [item1, item2, item3])
        try expectPublished(
            values: [
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                ),
                Pulse(
                    time: .zero,
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                ),
                Pulse(
                    time: CMTime(value: 1, timescale: 1),
                    timeRange: CMTimeRange(
                        start: .zero,
                        duration: CMTime(value: 1, timescale: 1)
                    )
                )
            ],
            from: Pulse.publisher(for: player, queue: .main),
            during: 4
        ) {
            player.play()
        }
    }
}
