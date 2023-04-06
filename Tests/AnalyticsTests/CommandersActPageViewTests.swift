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

    func testAppVersion() {
        expectAtLeastEqual(values: [PackageInfo.version], for: "app_library_version") { test in
            test.trackPageView(title: "\(#function)")
        }
    }

    func testSite() {
        expectAtLeastEqual(values: ["site"], for: "navigation_app_site_name") { test in
            test.trackPageView(title: "\(#function)")
        }
    }

    func testDevice() {
        expectAtLeastEqual(values: [UIDevice.current.model], for: "navigation_device") { test in
            test.trackPageView(title: "\(#function)")
        }
    }

    func testEventId() {
        expectAtLeastEqual(values: ["screen"], for: "event_id") { test in
            test.trackPageView(title: "\(#function)")
        }
    }

    func testNavigationPropertyType() {
        expectAtLeastEqual(values: ["app"], for: "navigation_property_type") { test in
            test.trackPageView(title: "\(#function)")
        }
    }
}
