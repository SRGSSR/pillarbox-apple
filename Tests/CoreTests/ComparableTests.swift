//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCore

import Nimble
import XCTest

final class ComparableTests: XCTestCase {
    func testClamped() {
        expect((-1).clamped(to: 0...1)).to(equal(0))
        expect(0.clamped(to: 0...1)).to(equal(0))
        expect(0.5.clamped(to: 0...1)).to(equal(0.5))
        expect(1.clamped(to: 0...1)).to(equal(1))
        expect(2.clamped(to: 0...1)).to(equal(1))
    }
}
