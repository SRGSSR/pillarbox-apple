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

    func testType() {
        expectAtLeastEqual(values: ["my-event-type"], for: "event_type") { test in
            test.trackEvent(type: "my-event-type")
        }
    }

    func testSource() {
        expectAtLeastEqual(values: ["my-event-source"], for: "event_source") { test in
            test.trackEvent(source: "my-event-source")
        }
    }
}
