//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import XCTest

final class CommandersActPageViewTests: XCTestCase {
    func testLabels() {
        expectAtLeastCommandersActEvents(
            [
                .page_view { labels in
                    expect(labels.page_type).to(equal("title"))
                    expect(labels.navigation_level_0).to(beNil())
                    expect(labels.navigation_level_1).to(equal("level_1"))
                    expect(labels.navigation_level_2).to(equal("level_2"))
                    expect(labels.navigation_level_3).to(equal("level_3"))
                    expect(labels.navigation_level_4).to(equal("level_4"))
                    expect(labels.navigation_level_5).to(equal("level_5"))
                    expect(labels.navigation_level_6).to(equal("level_6"))
                    expect(labels.navigation_level_7).to(equal("level_7"))
                    expect(labels.navigation_level_8).to(equal("level_8"))
                    expect(labels.navigation_level_9).to(beNil())
                    expect(["phone", "tablet", "tvbox", "phone"]).to(contain([labels.navigation_device]))
                    expect(labels.app_library_version).to(equal(PackageInfo.version))
                    expect(labels.navigation_app_site_name).to(equal("site"))
                    expect(labels.navigation_property_type).to(equal("app"))
                    expect(labels.navigation_bu_distributer).to(equal("RTS"))
                }
            ]
        ) {
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
        }
    }
}
