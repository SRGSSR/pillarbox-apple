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

    func testContentTitle() {
        expectAtLeastEqual(values: ["\(#function)"], for: "content_title") { test in
            test.trackPageView(title: "\(#function)")
        }
    }

    func testVendor() {
        expectAtLeastEqual(values: ["RTS"], for: "navigation_bu_distributer") { test in
            test.trackPageView(title: "\(#function)")
        }
    }

    func testLevel0() {
        expectNothingPublished(values: ["nothing"], for: "navigation_level_0") { test in
            test.trackPageView(title: "\(#function)", levels: [1, 2, 3, 4, 5, 6, 6, 8, 9, 10].map { "something_\($0)" })
        }
    }

    func testLevel1() {
        expectAtLeastEqual(values: ["something_1"], for: "navigation_level_1") { test in
            test.trackPageView(title: "\(#function)", levels: [1, 2, 3, 4, 5, 6, 6, 8, 9, 10].map { "something_\($0)" })
        }
    }

    func testLevel8() {
        expectAtLeastEqual(values: ["something_8"], for: "navigation_level_8") { test in
            test.trackPageView(title: "\(#function)", levels: [1, 2, 3, 4, 5, 6, 6, 8, 9, 10].map { "something_\($0)" })
        }
    }

    func testLevel9() {
        expectNothingPublished(values: ["nothing"], for: "navigation_level_9") { test in
            test.trackPageView(title: "\(#function)", levels: [1, 2, 3, 4, 5, 6, 6, 8, 9, 10].map { "something_\($0)" })
        }
    }
}
