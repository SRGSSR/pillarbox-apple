//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import AnalyticsTestBridge
import Nimble
import XCTest

final class AnalyticsTests1: ComScoreTestCase {
    override func setUp() {
        print("--> instance setup 1")
    }

    func test11() {
        expectEqual(values: ["6036016"], for: "c2", during: .seconds(10)) { context in
            context.trackPageView(title: "title")
        }
        expectEqual(values: ["6036016"], for: "c2", during: .seconds(4)) { test in
            test.trackPageView(title: "title")
        }
    }

    func test12() {
        print("--> 12")
    }
}
