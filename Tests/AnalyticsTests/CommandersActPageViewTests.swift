//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import AnalyticsTestBridge
import Nimble
import XCTest

final class CommandersActPageViewTests: CommandersActTestCase {
    func testLabels() {
        wait {
            Analytics.shared.sendPageView(title: "title", levels: [
                "level_1",
                "level_2",
                "level_3",
                "level_4",
                "level_5",
                "level_6",
                "level_7",
                "level_8"
            ])
        } received: { labels in
            expect(labels["page_type"] as? String).to(equal("title"))
            expect(labels["navigation_level_0"]).to(beNil())
            expect(labels["navigation_level_1"] as? String).to(equal("level_1"))
            expect(labels["navigation_level_2"] as? String).to(equal("level_2"))
            expect(labels["navigation_level_3"] as? String).to(equal("level_3"))
            expect(labels["navigation_level_4"] as? String).to(equal("level_4"))
            expect(labels["navigation_level_5"] as? String).to(equal("level_5"))
            expect(labels["navigation_level_6"] as? String).to(equal("level_6"))
            expect(labels["navigation_level_7"] as? String).to(equal("level_7"))
            expect(labels["navigation_level_8"] as? String).to(equal("level_8"))
            expect(labels["navigation_level_9"]).to(beNil())
            expect(["phone", "tablet", "tvbox", "phone"]).to(contain([labels["navigation_device"] as? String]))
            expect(labels["app_library_version"] as? String).to(equal(PackageInfo.version))
            expect(labels["navigation_app_site_name"] as? String).to(equal("site"))
            expect(labels["navigation_property_type"] as? String).to(equal("app"))
            expect(labels["navigation_bu_distributer"] as? String).to(equal("RTS"))
        }
    }
}
