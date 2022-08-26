//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import AVFoundation
import Nimble
import XCTest

final class StreamTypeTests: XCTestCase {
    func testUnknown() {
        expect(StreamType.streamType(for: nil)).to(equal(.unknown))
    }

    func testOnDemand() {
        let pulse = Pulse(
            time: .zero,
            timeRange: CMTimeRange(
                start: .zero,
                duration: CMTime(value: 10, timescale: 1)
            )
        )
        expect(StreamType.streamType(for: pulse)).to(equal(.onDemand))
    }

    func testLive() {
        let pulse = Pulse(
            time: .zero,
            timeRange: .zero
        )
        expect(StreamType.streamType(for: pulse)).to(equal(.live))
    }
}
