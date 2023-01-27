//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Nimble
import XCTest

final class StreamTypeTests: XCTestCase {
    func testUnknown() {
        let streamType = StreamType(for: .invalid, itemDuration: .invalid)
        expect(streamType).to(equal(.unknown))
    }

    func testLive() {
        let streamType = StreamType(for: .zero, itemDuration: .indefinite)
        expect(streamType).to(equal(.live))
    }

    func testDvr() {
        let start = CMTime(value: 0, timescale: 1)
        let end = CMTime(value: 1, timescale: 1)
        let streamType = StreamType(for: .init(start: start, end: end), itemDuration: .indefinite)
        expect(streamType).to(equal(.dvr))
    }

    func testOnDemand() {
        let start = CMTime(value: 0, timescale: 1)
        let end = CMTime(value: 1, timescale: 1)
        let streamType = StreamType(for: .init(start: start, end: end), itemDuration: end)
        expect(streamType).to(equal(.onDemand))
    }
}
