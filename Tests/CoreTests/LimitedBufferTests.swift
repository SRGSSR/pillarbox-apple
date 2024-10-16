//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Nimble
import PillarboxCircumspect
import XCTest

final class LimitedBufferTests: XCTestCase {
    func testBufferWithZeroSize() {
        let buffer = LimitedBuffer<Int>(size: 0)
        expect(buffer.values).to(beEmpty())
        buffer.append(1)
        expect(buffer.values).to(beEmpty())
    }

    func testBufferWithFiniteSize() {
        let buffer = LimitedBuffer<Int>(size: 2)
        expect(buffer.values).to(beEmpty())
        buffer.append(1)
        expect(buffer.values).to(equal([1]))
        buffer.append(2)
        expect(buffer.values).to(equal([1, 2]))
        buffer.append(3)
        expect(buffer.values).to(equal([2, 3]))
    }
}
