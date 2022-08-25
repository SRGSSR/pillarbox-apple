//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class PulseTests: XCTestCase {
    func testProgress() {
        let pulse = Pulse(
            time: CMTime(value: 10, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 0, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )
        expect(pulse.progress).to(equal(0.5))
    }

    func testProgressLowerBound() {
        let pulse = Pulse(
            time: CMTime(value: 10, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 30, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )
        expect(pulse.progress).to(equal(0))
    }

    func testProgressUpperBound() {
        let pulse = Pulse(
            time: CMTime(value: 40, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )
        expect(pulse.progress).to(equal(1))
    }

    func testProgressForInvalidTime() {
        let pulse = Pulse(
            time: .invalid,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )
        expect(pulse.progress).to(equal(0))
    }

    func testProgressForIndefiniteTime() {
        let pulse = Pulse(
            time: .indefinite,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )
        expect(pulse.progress).to(equal(0))
    }

    func testProgressForNegativeInfinityTime() {
        let pulse = Pulse(
            time: .negativeInfinity,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )
        expect(pulse.progress).to(equal(0))
    }

    func testProgressForPositiveInfinityTime() {
        let pulse = Pulse(
            time: .positiveInfinity,
            timeRange: CMTimeRange(
                start: CMTime(value: 10, timescale: 1),
                duration: CMTime(value: 20, timescale: 1)
            )
        )
        expect(pulse.progress).to(equal(0))
    }

    func testProgressForEmptyTimeRange() {
        let pulse = Pulse(
            time: CMTime(value: 100, timescale: 1),
            timeRange: .zero
        )
        expect(pulse.progress).to(equal(0))
    }

    func testProgressForInvalidTimeRange() {
        let pulse = Pulse(
            time: CMTime(value: 100, timescale: 1),
            timeRange: .invalid
        )
        expect(pulse.progress).to(equal(0))
    }

    func testTimeForProgress() {

    }
}
