//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Combine
import Nimble
import PillarboxCircumspect
import XCTest

final class DemandBufferTests: XCTestCase {
    func testEmptyBuffer() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.values).to(beEmpty())
        expect(buffer.requested).to(equal(Subscribers.Demand.none))
    }

    func testAppendWithoutRequest() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.append(1)).to(beEmpty())
        expect(buffer.append(2)).to(beEmpty())
        expect(buffer.values).to(equalDiff([1, 2]))
    }

    func testLimitedRequestWithEmptyBuffer() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.request(.max(2))).to(beEmpty())
        expect(buffer.requested).to(equal(.max(2)))
    }

    func testLimitedRequestWithPartiallyFilledBuffer() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.append(1)).to(beEmpty())
        expect(buffer.append(2)).to(beEmpty())
        expect(buffer.request(.max(10))).to(equalDiff([.produce(1), .produce(2)]))
        expect(buffer.requested).to(equal(.max(8)))
    }

    func testLimitedRequestWithFullyFilledBuffer() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.append(1)).to(beEmpty())
        expect(buffer.append(2)).to(beEmpty())
        expect(buffer.append(3)).to(beEmpty())
        expect(buffer.append(4)).to(beEmpty())
        expect(buffer.request(.max(2))).to(equalDiff([.produce(1), .produce(2), .complete]))
        expect(buffer.requested).to(equal(.max(0)))
        expect(buffer.append(5)).to(beEmpty())
    }

    func testUnlimitedRequestWithEmptyBuffer() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.request(.unlimited)).to(beEmpty())
        expect(buffer.requested).to(equal(.unlimited))
    }

    func testUnlimitedRequestWithFilledBuffer() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.append(1)).to(beEmpty())
        expect(buffer.append(2)).to(beEmpty())
        expect(buffer.request(.unlimited)).to(equalDiff([.produce(1), .produce(2)]))
        expect(buffer.requested).to(equal(.unlimited))
    }

    func testAppendWithPendingLimitedRequest() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.request(.max(2))).to(beEmpty())
        expect(buffer.append(1)).to(equalDiff([.produce(1)]))
        expect(buffer.append(2)).to(equalDiff([.produce(2), .complete]))
        expect(buffer.requested).to(equal(.max(0)))
        expect(buffer.append(3)).to(beEmpty())
    }

    func testAppendWithPendingUnlimitedRequest() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.request(.unlimited)).to(beEmpty())
        expect(buffer.append(1)).to(equalDiff([.produce(1)]))
        expect(buffer.append(2)).to(equalDiff([.produce(2)]))
    }
}
