//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class PulseCreationTests: XCTestCase {
    func testValid() {
        expect(Pulse(time: .zero, timeRange: .zero, itemDuration: .indefinite)).notTo(beNil())
        expect(Pulse(
            time: CMTime(value: 1, timescale: 1),
            timeRange: .zero,
            itemDuration: .indefinite
        )).notTo(beNil())
        expect(Pulse(
            time: .zero,
            timeRange: CMTimeRange(
                start: CMTime(value: 1, timescale: 1),
                duration: CMTime(value: 10, timescale: 1)
            ),
            itemDuration: CMTime(value: 10, timescale: 1)
        )).notTo(beNil())
        expect(Pulse(
            time: CMTime(value: 1, timescale: 1),
            timeRange: CMTimeRange(
                start: CMTime(value: 1, timescale: 1),
                duration: CMTime(value: 10, timescale: 1)
            ),
            itemDuration: CMTime(value: 10, timescale: 1)
        )).notTo(beNil())
    }

    func testInvalid() {
        expect(Pulse(time: .invalid, timeRange: .zero, itemDuration: .indefinite)).to(beNil())
        expect(Pulse(time: .indefinite, timeRange: .zero, itemDuration: .indefinite)).to(beNil())
        expect(Pulse(time: .positiveInfinity, timeRange: .zero, itemDuration: .indefinite)).to(beNil())
        expect(Pulse(time: .negativeInfinity, timeRange: .zero, itemDuration: .indefinite)).to(beNil())
        expect(Pulse(time: .zero, timeRange: .invalid, itemDuration: .indefinite)).to(beNil())
    }
}
