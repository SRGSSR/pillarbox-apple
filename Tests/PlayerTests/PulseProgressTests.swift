//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class PulseProgressTests: XCTestCase {
    func testProgress() {
        let pulse = Pulse(
            time: CMTime(value: 10, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 0, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            ),
            itemDuration: CMTime(value: 20, timescale: 1)
        )!
        expect(pulse.progress).to(equal(0.5))
    }

    func testProgressBelowLowerBound() {
        let pulse = Pulse(
            time: CMTime(value: 10, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 30, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            ),
            itemDuration: CMTime(value: 20, timescale: 1)
        )!
        expect(pulse.progress).to(equal(0))
    }

    func testProgressAboveUpperBound() {
        let pulse = Pulse(
            time: CMTime(value: 40, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            ),
            itemDuration: CMTime(value: 20, timescale: 1)
        )!
        expect(pulse.progress).to(equal(1))
    }

    func testProgressForEmptyTimeRange() {
        let pulse = Pulse(
            time: CMTime(value: 100, timescale: 1),
            timeRange: .zero,
            itemDuration: .indefinite
        )!
        expect(pulse.progress).to(beNil())
    }
}
