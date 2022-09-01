//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class PlaybackPropertiesTests: XCTestCase {
    func testNilPulse() {
        let properties = PlaybackProperties(pulse: nil, targetTime: nil)
        expect(properties.progress).to(beNil())
    }

    func testPulse() {
        let properties = PlaybackProperties(
            pulse: Pulse(
                time: CMTime(value: 50, timescale: 1),
                timeRange: CMTimeRange(start: .zero, end: CMTime(value: 100, timescale: 1)),
                itemDuration: CMTime(value: 100, timescale: 1)
            ),
            targetTime: nil
        )
        expect(properties.progress).to(equal(0.5))
    }
}
