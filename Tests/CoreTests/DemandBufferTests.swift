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

    func testPrefilledBuffer() {
        let buffer: DemandBuffer = [1, 2]
        expect(buffer.values).to(equal([1, 2]))
    }

    func testLimitedRequestWithEmptyBuffer() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.request(.max(2))).to(beEmpty())
        expect(buffer.requested).to(equal(.max(2)))
    }

    func testLimitedRequestWithPartiallyFilledBuffer() {
        let buffer: DemandBuffer = [1, 2]
        expect(buffer.request(.max(10))).to(equal([1, 2]))
        expect(buffer.requested).to(equal(.max(8)))
    }

    func testLimitedRequestWithFullyFilledBuffer() {
        let buffer: DemandBuffer = [1, 2, 3, 4]
        expect(buffer.request(.max(2))).to(equal([1, 2]))
        expect(buffer.requested).to(equal(.max(0)))
        expect(buffer.append(5)).to(beEmpty())
    }

    func testUnlimitedRequestWithEmptyBuffer() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.request(.unlimited)).to(beEmpty())
        expect(buffer.requested).to(equal(.unlimited))
    }

    func testUnlimitedRequestWithFilledBuffer() {
        let buffer: DemandBuffer = [1, 2]
        expect(buffer.request(.unlimited)).to(equal([1, 2]))
        expect(buffer.requested).to(equal(.unlimited))
    }

    func testAppendWithPendingLimitedRequest() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.request(.max(2))).to(beEmpty())
        expect(buffer.append(1)).to(equal([1]))
        expect(buffer.append(2)).to(equal([2]))
        expect(buffer.requested).to(equal(.max(0)))
        expect(buffer.append(3)).to(beEmpty())
    }

    func testAppendWithPendingUnlimitedRequest() {
        let buffer = DemandBuffer<Int>()
        expect(buffer.request(.unlimited)).to(beEmpty())
        expect(buffer.append(1)).to(equal([1]))
        expect(buffer.append(2)).to(equal([2]))
    }

    func testThreadSafety() {
        let buffer = DemandBuffer([0...1000])
        for _ in 0..<100 {
            DispatchQueue.global().async {
                _ = buffer.request(.unlimited)
            }
        }
    }
}
