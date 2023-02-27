//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Nimble
import XCTest

class TestCase: XCTestCase {
    override class func setUp() {
        AsyncDefaults.timeout = .seconds(10)
    }

    override class func tearDown() {
        AsyncDefaults.timeout = .seconds(1)
    }
}
