//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxPlayer

import CoreMedia
import Nimble

final class CMTimeRangeTests: TestCase {
    func testEmpty() {
        expect(CMTimeRange.flatten([])).to(beEmpty())
    }

    func testNoOverlap() {
        let timeRanges: [CMTimeRange] = [
            .init(start: .init(value: 1, timescale: 1), end: .init(value: 10, timescale: 1)),
            .init(start: .init(value: 20, timescale: 1), end: .init(value: 30, timescale: 1))
        ]
        expect(CMTimeRange.flatten(timeRanges)).to(equal(timeRanges))
    }

    func testOverlap() {
        let timeRanges: [CMTimeRange] = [
            .init(start: .init(value: 1, timescale: 1), end: .init(value: 10, timescale: 1)),
            .init(start: .init(value: 5, timescale: 1), end: .init(value: 30, timescale: 1))
        ]
        expect(CMTimeRange.flatten(timeRanges)).to(equal(
            [
                .init(start: .init(value: 1, timescale: 1), end: .init(value: 30, timescale: 1))
            ]
        ))
    }

    func testContained() {
        let timeRanges: [CMTimeRange] = [
            .init(start: .init(value: 1, timescale: 1), end: .init(value: 10, timescale: 1)),
            .init(start: .init(value: 2, timescale: 1), end: .init(value: 8, timescale: 1))
        ]
        expect(CMTimeRange.flatten(timeRanges)).to(equal(
            [
                .init(start: .init(value: 1, timescale: 1), end: .init(value: 10, timescale: 1))
            ]
        ))
    }
}
