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
            test.sendPageView(title: "title")
        }
    }

    func testAppVersion() {
        expectAtLeastEqual(values: [PackageInfo.version], for: "app_library_version") { test in
            test.sendPageView(title: "\(#function)")
        }
    }

    func testSite() {
        expectAtLeastEqual(values: ["site"], for: "navigation_app_site_name") { test in
            test.sendPageView(title: "\(#function)")
        }
    }

    func testDevice() {
        expectAtLeastEqual(values: [UIDevice.current.model], for: "navigation_device") { test in
            test.sendPageView(title: "\(#function)")
        }
    }

    func testNavigationPropertyType() {
        expectAtLeastEqual(values: ["app"], for: "navigation_property_type") { test in
            test.sendPageView(title: "\(#function)")
        }
    }

    func testVendor() {
        expectAtLeastEqual(values: ["RTS"], for: "navigation_bu_distributer") { test in
            test.sendPageView(title: "\(#function)")
        }
    }

    func testLevel0() {
        expectNothingPublished(for: "navigation_level_0", during: .seconds(3)) { test in
            test.sendPageView(title: "\(#function)", levels: (1...10).map { "something_\($0)" })
        }
    }

    func testLevel1() {
        expectAtLeastEqual(values: ["something_1"], for: "navigation_level_1") { test in
            test.sendPageView(title: "\(#function)", levels: (1...10).map { "something_\($0)" })
        }
    }

    func testLevel8() {
        expectAtLeastEqual(values: ["something_8"], for: "navigation_level_8") { test in
            test.sendPageView(title: "\(#function)", levels: (1...10).map { "something_\($0)" })
        }
    }

    func testLevel9() {
        expectNothingPublished(for: "navigation_level_9", during: .seconds(3)) { test in
            test.sendPageView(title: "\(#function)", levels: (1...10).map { "something_\($0)" })
        }
    }
}
