//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import PillarboxCircumspect

import Nimble
import XCTest

final class ComparatorTests: XCTestCase {
    func testClose() {
        expect(beClose(within: 0.1)(0.3, 0.3)).to(beTrue())
    }

    func testDistant() {
        expect(beClose(within: 0.1)(0.3, 0.5)).to(beFalse())
    }
}
