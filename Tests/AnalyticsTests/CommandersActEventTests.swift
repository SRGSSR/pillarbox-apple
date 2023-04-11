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

    func testExtra1() {
        expectAtLeastEqual(values: ["my-event-extra1"], for: "event_value_1") { test in
            test.trackEvent(extra1: "my-event-extra1")
        }
    }

    func testExtra2() {
        expectAtLeastEqual(values: ["my-event-extra2"], for: "event_value_2") { test in
            test.trackEvent(extra2: "my-event-extra2")
        }
    }

    func testExtra3() {
        expectAtLeastEqual(values: ["my-event-extra3"], for: "event_value_3") { test in
            test.trackEvent(extra3: "my-event-extra3")
        }
    }

    func testExtra4() {
        expectAtLeastEqual(values: ["my-event-extra4"], for: "event_value_4") { test in
            test.trackEvent(extra4: "my-event-extra4")
        }
    }

    func testExtra5() {
        expectAtLeastEqual(values: ["my-event-extra5"], for: "event_value_5") { test in
            test.trackEvent(extra5: "my-event-extra5")
        }
    }
}
