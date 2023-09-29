//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble

final class TimePropertiesTests: TestCase {
    func testWithoutTimeRange() {
        expect(TimeProperties.timeRange(from: [])).to(beNil())
    }

    func testTimeRange() {
        expect(TimeProperties.timeRange(from: [NSValue(timeRange: .finite)])).to(equal(.finite))
    }

    func testTimeRanges() {
        expect(TimeProperties.timeRange(from: [
            NSValue(timeRange: .init(start: .init(value: 1, timescale: 1), duration: .init(value: 3, timescale: 1))),
            NSValue(timeRange: .init(start: .init(value: 10, timescale: 1), duration: .init(value: 5, timescale: 1)))
        ])).to(equal(
            .init(start: .init(value: 1, timescale: 1), duration: .init(value: 14, timescale: 1))
        ))
    }

    func testInvalidTimeRange() {
        expect(TimeProperties.timeRange(from: [NSValue(timeRange: .invalid)])).to(equal(.invalid))
    }

    func testSeekableTimeRangeFallback() {
        expect(
            TimeProperties.timeRange(
                loadedTimeRanges: [NSValue(timeRange: .finite)],
                seekableTimeRanges: []
            )
        )
        .to(equal(.zero))
    }

    func testBufferEmptyLoadedTimeRanges() {
        expect(
            TimeProperties(
                loadedTimeRanges: [],
                seekableTimeRanges: [NSValue(timeRange: .finite)]
            ).buffer
        )
        .to(equal(0))
    }

    func testBuffer() {
        expect(
            TimeProperties(
                loadedTimeRanges: [NSValue(timeRange: .finite)],
                seekableTimeRanges: [NSValue(timeRange: .finite)]
            ).buffer
        )
        .to(equal(1))
    }
}

private extension CMTimeRange {
    static var finite: Self {
        .init(start: .zero, duration: .init(value: 1, timescale: 1))
    }
}
