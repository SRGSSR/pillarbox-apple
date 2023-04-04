//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import AnalyticsTestBridge
import XCTest

final class CommandersActPageViewTests: CommandersActTestCase {
    func testTitle() {
        expectAtLeastEqual(values: ["title"], for: "page_type") { test in
            test.trackPageView(title: "title")
        }
    }
}
