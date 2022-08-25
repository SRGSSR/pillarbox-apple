//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class TimeRangeTests: XCTestCase {
    
}

final class CloseTests: XCTestCase {
    func testCloseWithFiniteTimes() {
        expect(Time.close(within: 0)(CMTime.zero, .zero)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.zero, .zero)).to(beTrue())

        expect(Time.close(within: 0.5)(CMTime(value: 2, timescale: 1), CMTime(value: 2, timescale: 1))).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime(value: 2, timescale: 1), CMTime(value: 200, timescale: 100))).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.zero, CMTime(value: 1, timescale: 2))).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.zero, CMTime(value: 2, timescale: 1))).to(beFalse())

        expect(Time.close(within: 0)(CMTime.zero, CMTime(value: 1, timescale: 10000))).to(beFalse())
    }

    func testCloseWithPositiveInfiniteValues() {
        expect(Time.close(within: 0)(CMTime.positiveInfinity, .positiveInfinity)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.positiveInfinity, .positiveInfinity)).to(beTrue())

        expect(Time.close(within: 10000)(CMTime.positiveInfinity, .zero)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.positiveInfinity, .negativeInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.positiveInfinity, .indefinite)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.positiveInfinity, .invalid)).to(beFalse())
    }

    func testCloseWithMinusInfiniteValues() {
        expect(Time.close(within: 0)(CMTime.negativeInfinity, .negativeInfinity)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.negativeInfinity, .negativeInfinity)).to(beTrue())

        expect(Time.close(within: 10000)(CMTime.negativeInfinity, .zero)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.negativeInfinity, .positiveInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.negativeInfinity, .indefinite)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.negativeInfinity, .invalid)).to(beFalse())
    }

    func testCloseWithIndefiniteValues() {
        expect(Time.close(within: 0)(CMTime.indefinite, .indefinite)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.indefinite, .indefinite)).to(beTrue())

        expect(Time.close(within: 10000)(CMTime.indefinite, .zero)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.indefinite, .positiveInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.indefinite, .negativeInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.indefinite, .invalid)).to(beFalse())
    }

    func testCloseWithInvalidValues() {
        expect(Time.close(within: 0)(CMTime.invalid, .invalid)).to(beTrue())
        expect(Time.close(within: 0.5)(CMTime.invalid, .invalid)).to(beTrue())

        expect(Time.close(within: 10000)(CMTime.invalid, .zero)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.invalid, .positiveInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.invalid, .negativeInfinity)).to(beFalse())
        expect(Time.close(within: 10000)(CMTime.invalid, .indefinite)).to(beFalse())
    }
}
