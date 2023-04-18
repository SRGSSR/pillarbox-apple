//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation
import Nimble
import XCTest

/// A simple test suite with more tolerant Nimble settings. Beware that `toAlways` and `toNever` expectations appearing
/// in tests will use the same value by default and should likely always provide an explicit `until` parameter.
class TestCase: XCTestCase {
    override class func setUp() {
        PollingDefaults.timeout = .seconds(20)
    }

    override class func tearDown() {
        PollingDefaults.timeout = .seconds(1)
    }
}
