//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import AnalyticsTestBridge
import XCTest

final class ComScorePageViewTests: ComScoreTestCase {
    func testTitle() {
        expectAtLeastEqual(values: ["title"], for: "name") { test in
            test.trackPageView(title: "title")
        }
    }
}
