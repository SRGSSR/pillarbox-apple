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
        expect(stopwatch.time()).to(equal(0))
    }

    func testStart() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(500))
        expect(stopwatch.time() * 1000).to(beCloseTo(500, within: 100))
    }

    func testStartAndStop() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(200))
        stopwatch.stop()
        wait(for: .milliseconds(200))
        expect(stopwatch.time() * 1000).to(beCloseTo(200, within: 100))
    }

    func testStopWithoutStart() {
        let stopwatch = Stopwatch()
        stopwatch.stop()
        wait(for: .milliseconds(200))
        expect(stopwatch.time() * 1000).to(beCloseTo(0, within: 100))
    }

    func testReset() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(200))
        stopwatch.reset()
        wait(for: .milliseconds(100))
        expect(stopwatch.time()).to(equal(0))
    }

    func testMultipleStarts() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(200))
        stopwatch.start()
        wait(for: .milliseconds(200))
        expect(stopwatch.time() * 1000).to(beCloseTo(400, within: 100))
    }

    func testAccumulation() {
        let stopwatch = Stopwatch()
        stopwatch.start()
        wait(for: .milliseconds(200))
        stopwatch.stop()
        wait(for: .milliseconds(200))
        stopwatch.start()
        wait(for: .milliseconds(200))
        expect(stopwatch.time() * 1000).to(beCloseTo(400, within: 100))
    }
}
