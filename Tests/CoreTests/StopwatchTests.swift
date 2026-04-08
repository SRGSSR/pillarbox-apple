//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Nimble
import XCTest

final class StopwatchTests: XCTestCase {
    func testCreation() {
        let stopwatch = Stopwatch()
        wait(for: .milliseconds(500))
        expect(stopwatch.duration().timeInterval()).to(equal(0))
    }

    func testStart() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(500))
        expect(stopwatch.duration().timeInterval()).to(beCloseTo(0.5, within: 0.1))
    }

    func testStartAndStop() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(200))
        stopwatch.stop()
        wait(for: .milliseconds(200))
        expect(stopwatch.duration().timeInterval()).to(beCloseTo(0.2, within: 0.1))
    }

    func testStopWithoutStart() {
        let stopwatch = Stopwatch()
        stopwatch.stop()
        wait(for: .milliseconds(200))
        expect(stopwatch.duration().timeInterval()).to(beCloseTo(0, within: 0.1))
    }

    func testReset() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(200))
        stopwatch.reset()
        wait(for: .milliseconds(100))
        expect(stopwatch.duration().timeInterval()).to(equal(0))
    }

    func testMultipleStarts() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(200))
        stopwatch.start()
        wait(for: .milliseconds(200))
        expect(stopwatch.duration().timeInterval()).to(beCloseTo(0.4, within: 0.1))
    }

    func testAccumulation() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(200))
        stopwatch.stop()
        wait(for: .milliseconds(200))
        stopwatch.start()
        wait(for: .milliseconds(200))
        expect(stopwatch.duration().timeInterval()).to(beCloseTo(0.4, within: 0.1))
    }
}
