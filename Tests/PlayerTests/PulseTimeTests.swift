//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class PulseTimeTests: XCTestCase {
    func testTimeForProgress() {
        let pulse = Pulse(
            time: .zero,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 30, timescale: 1)
            ),
            itemDuration: CMTime(value: 30, timescale: 1)
        )!
        expect(pulse.time(forProgress: 0.5)).to(equal(CMTime(value: 25, timescale: 1)))
    }

    func testTimeForProgressBelowLowerBound() {
        let pulse = Pulse(
            time: .zero,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 30, timescale: 1)
            ),
            itemDuration: CMTime(value: 30, timescale: 1)
        )!
        expect(pulse.time(forProgress: -1)).to(equal(CMTime(value: 10, timescale: 1)))
    }

    func testTimeForProgressAboveUpperBound() {
        let pulse = Pulse(
            time: .zero,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 30, timescale: 1)
            ),
            itemDuration: CMTime(value: 30, timescale: 1)
        )!
        expect(pulse.time(forProgress: 2)).to(equal(CMTime(value: 40, timescale: 1)))
    }

    func testTimeForProgressWithEmptyTimeRange() {
        let pulse = Pulse(time: .zero, timeRange: .zero, itemDuration: .indefinite)!
        expect(pulse.time(forProgress: 2)).to(beNil())
    }
}
