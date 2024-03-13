//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Nimble
import XCTest

/// A simple test suite with more tolerant Nimble settings. Beware that `toAlways` and `toNever` expectations appearing
/// in tests will use the same value by default and should likely always provide an explicit `until` parameter.
class TestCase: XCTestCase {
    override class func setUp() {
        PollingDefaults.timeout = .seconds(20)
        PollingDefaults.pollInterval = .milliseconds(100)
    }

    override class func tearDown() {
        PollingDefaults.timeout = .seconds(1)
        PollingDefaults.pollInterval = .milliseconds(10)
    }
}
