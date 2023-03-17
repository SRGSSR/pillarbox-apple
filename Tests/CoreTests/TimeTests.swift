//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Core

import CoreMedia
import Nimble
import XCTest

final class TimeTests: XCTestCase {
    func testCloseWithFiniteTimes() {
        expect(CMTime.close(within: 0)(CMTime.zero, .zero)).to(beTrue())
        expect(CMTime.close(within: 0.5)(CMTime.zero, .zero)).to(beTrue())

        expect(CMTime.close(within: 0.5)(CMTime(value: 2, timescale: 1), CMTime(value: 2, timescale: 1))).to(beTrue())
        expect(CMTime.close(within: 0.5)(CMTime(value: 2, timescale: 1), CMTime(value: 200, timescale: 100))).to(beTrue())
        expect(CMTime.close(within: 0.5)(CMTime.zero, CMTime(value: 1, timescale: 2))).to(beTrue())
        expect(CMTime.close(within: 0.5)(CMTime.zero, CMTime(value: 2, timescale: 1))).to(beFalse())

        expect(CMTime.close(within: 0)(CMTime.zero, CMTime(value: 1, timescale: 10000))).to(beFalse())
    }

    func testCloseWithPositiveInfiniteValues() {
        expect(CMTime.close(within: 0)(CMTime.positiveInfinity, .positiveInfinity)).to(beTrue())
        expect(CMTime.close(within: 0.5)(CMTime.positiveInfinity, .positiveInfinity)).to(beTrue())

        expect(CMTime.close(within: 10000)(CMTime.positiveInfinity, .zero)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.positiveInfinity, .negativeInfinity)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.positiveInfinity, .indefinite)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.positiveInfinity, .invalid)).to(beFalse())
    }

    func testCloseWithMinusInfiniteValues() {
        expect(CMTime.close(within: 0)(CMTime.negativeInfinity, .negativeInfinity)).to(beTrue())
        expect(CMTime.close(within: 0.5)(CMTime.negativeInfinity, .negativeInfinity)).to(beTrue())

        expect(CMTime.close(within: 10000)(CMTime.negativeInfinity, .zero)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.negativeInfinity, .positiveInfinity)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.negativeInfinity, .indefinite)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.negativeInfinity, .invalid)).to(beFalse())
    }

    func testCloseWithIndefiniteValues() {
        expect(CMTime.close(within: 0)(CMTime.indefinite, .indefinite)).to(beTrue())
        expect(CMTime.close(within: 0.5)(CMTime.indefinite, .indefinite)).to(beTrue())

        expect(CMTime.close(within: 10000)(CMTime.indefinite, .zero)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.indefinite, .positiveInfinity)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.indefinite, .negativeInfinity)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.indefinite, .invalid)).to(beFalse())
    }

    func testCloseWithInvalidValues() {
        expect(CMTime.close(within: 0)(CMTime.invalid, .invalid)).to(beTrue())
        expect(CMTime.close(within: 0.5)(CMTime.invalid, .invalid)).to(beTrue())

        expect(CMTime.close(within: 10000)(CMTime.invalid, .zero)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.invalid, .positiveInfinity)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.invalid, .negativeInfinity)).to(beFalse())
        expect(CMTime.close(within: 10000)(CMTime.invalid, .indefinite)).to(beFalse())
    }

    func testTimeRangeIsValidAndNotEmpty() {
        expect(CMTimeRange.invalid.isValidAndNotEmpty).to(beFalse())
        expect(CMTimeRange.zero.isValidAndNotEmpty).to(beFalse())
        expect(CMTimeRange(
            start: CMTime(value: 1, timescale: 1),
            end: CMTime(value: 1, timescale: 1)
        ).isValidAndNotEmpty).to(beFalse())
        expect(CMTimeRange(
            start: CMTime(value: 0, timescale: 1),
            end: CMTime(value: 1, timescale: 1)
        ).isValidAndNotEmpty).to(beTrue())
    }
}
