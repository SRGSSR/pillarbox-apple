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
        expectAtLeastEqual(values: ["title"], for: "ns_category") { test in
            test.sendPageView(title: "title")
        }
    }

    func testBrand() {
        expectAtLeastEqual(values: ["RTS"], for: "mp_brand") { test in
            test.sendPageView(title: "\(#function)")
        }
    }
}
