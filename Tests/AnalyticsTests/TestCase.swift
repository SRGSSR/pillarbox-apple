//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Analytics
import Foundation
import Nimble
import XCTest

/// A simple test suite with more tolerant Nimble settings. Beware that `toAlways` and `toNever` expectations appearing
/// in tests will use the same value by default and should likely always provide an explicit `until` parameter.
class TestCase: XCTestCase {
    override class func setUp() {
        PollingDefaults.timeout = .seconds(20)
        try? Analytics.shared.start(with: .init(vendor: .SRG, sourceKey: "source", appSiteName: "site"))
    }

    override class func tearDown() {
        PollingDefaults.timeout = .seconds(1)
    }

    override func setUp() {
        waitUntil { done in
            AnalyticsListener.start(completion: done)
        }
    }
}
