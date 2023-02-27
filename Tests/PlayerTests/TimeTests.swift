//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class TimeTests: TestCase {
    func testClampedWithNonEmptyRange() {
        let range = CMTimeRange(start: CMTime(value: 1, timescale: 1), end: CMTime(value: 10, timescale: 1))
        expect(CMTime.zero.clamped(to: range)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime.invalid.clamped(to: range)).to(equal(.invalid))
        expect(CMTime(value: 1, timescale: 1).clamped(to: range)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime(value: 5, timescale: 1).clamped(to: range)).to(equal(CMTime(value: 5, timescale: 1)))
        expect(CMTime(value: 10, timescale: 1).clamped(to: range)).to(equal(CMTime(value: 10, timescale: 1)))
        expect(CMTime(value: 20, timescale: 1).clamped(to: range)).to(equal(CMTime(value: 10, timescale: 1)))
    }

    func testClampedWithNonEmptyRangeAndOffset() {
        let range = CMTimeRange(start: CMTime(value: 1, timescale: 1), end: CMTime(value: 10, timescale: 1))
        let offset = CMTime(value: 1, timescale: 10)
        expect(CMTime.zero.clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime.invalid.clamped(to: range, offset: offset)).to(equal(.invalid))
        expect(CMTime(value: 1, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime(value: 5, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 5, timescale: 1)))
        expect(CMTime(value: 10, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 99, timescale: 10)))
        expect(CMTime(value: 20, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 99, timescale: 10)))
    }

    func testClampedWithNonEmptyRangeAndLargeOffset() {
        let range = CMTimeRange(start: CMTime(value: 1, timescale: 1), end: CMTime(value: 10, timescale: 1))
        let offset = CMTime(value: 100, timescale: 1)
        expect(CMTime.zero.clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime.invalid.clamped(to: range, offset: offset)).to(equal(.invalid))
        expect(CMTime(value: 1, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime(value: 5, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime(value: 10, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime(value: 20, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
    }

    func testClampedWithEmptyRange() {
        let range = CMTimeRange(start: CMTime(value: 1, timescale: 1), end: CMTime(value: 1, timescale: 1))
        expect(CMTime.zero.clamped(to: range)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime.invalid.clamped(to: range)).to(equal(.invalid))
        expect(CMTime(value: 1, timescale: 1).clamped(to: range)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime(value: 5, timescale: 1).clamped(to: range)).to(equal(CMTime(value: 1, timescale: 1)))
    }

    func testClampedWithEmptyRangeAndOffset() {
        let range = CMTimeRange(start: CMTime(value: 1, timescale: 1), end: CMTime(value: 1, timescale: 1))
        let offset = CMTime(value: 1, timescale: 10)
        expect(CMTime.zero.clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime.invalid.clamped(to: range, offset: offset)).to(equal(.invalid))
        expect(CMTime(value: 1, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
        expect(CMTime(value: 5, timescale: 1).clamped(to: range, offset: offset)).to(equal(CMTime(value: 1, timescale: 1)))
    }

    func testClampedWithInvalidRange() {
        let range = CMTimeRange.invalid
        expect(CMTime.zero.clamped(to: range)).to(equal(.invalid))
        expect(CMTime.invalid.clamped(to: range)).to(equal(.invalid))
        expect(CMTime(value: 1, timescale: 1).clamped(to: range)).to(equal(.invalid))
    }

    func testClampedWithInvalidRangeAndOffset() {
        let range = CMTimeRange.invalid
        let offset = CMTime(value: 1, timescale: 10)
        expect(CMTime.zero.clamped(to: range, offset: offset)).to(equal(.invalid))
        expect(CMTime.invalid.clamped(to: range, offset: offset)).to(equal(.invalid))
        expect(CMTime(value: 1, timescale: 1).clamped(to: range, offset: offset)).to(equal(.invalid))
    }
}
