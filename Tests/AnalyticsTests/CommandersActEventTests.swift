//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import AnalyticsTestBridge
import XCTest

final class CommandersActEventTests: CommandersActTestCase {
    func testName() {
        expectAtLeastEqual(values: ["my-event"], for: "event_name") { test in
            test.trackEvent(name: "my-event")
        }
    }
}
