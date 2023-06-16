//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Nimble
import UIKit
import XCTest

private class AutomaticMockViewController: UIViewController, PageViewTracking {
    var pageTitle: String {
        "automatic"
    }
}

private class AutomaticWithLevelsMockViewController: UIViewController, PageViewTracking {
    var pageTitle: String {
        "automatic_with_levels"
    }

    var pageLevels: [String] {
        ["level1", "level2"]
    }
}

private class ManualMockViewController: UIViewController, PageViewTracking {
    var pageTitle: String {
        "manual"
    }

    var isTrackedAutomatically: Bool {
        false
    }
}

final class ComScorePageViewTests: ComScoreTestCase {
    func testLabels() {
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c2).to(equal("6036016"))
                expect(labels.ns_ap_an).to(equal("xctest"))
                expect(labels.ns_category).to(equal("title"))
                expect(labels.ns_st_mp).to(beNil())
                expect(labels.ns_st_mv).to(beNil())
                expect(labels.mp_brand).to(equal("SRG"))
                expect(labels.mp_v).notTo(beEmpty())
            }
        ) {
            Analytics.shared.trackPageView(title: "title")
        }
    }

    func testDefaultProtocolImplementation() {
        let viewController = AutomaticMockViewController()
        expect(viewController.pageLevels).to(beEmpty())
        expect(viewController.isTrackedAutomatically).to(beTrue())
    }

    func testCustomProtocolImplementation() {
        let viewController = AutomaticWithLevelsMockViewController()
        expect(viewController.pageLevels).to(equal(["level1", "level2"]))
        expect(viewController.isTrackedAutomatically).to(beTrue())
    }

    func testAutomaticTrackingWithoutProtocolImplementation() {
        let viewController = UIViewController()
        expectNoEvents(during: .seconds(2)) {
            viewController.viewDidAppear(false)
        }
    }

    func testManualTrackingWithoutProtocolImplementation() {
        let viewController = UIViewController()
        expectNoEvents(during: .seconds(2)) {
            viewController.trackPageView()
        }
    }

    func testAutomaticTrackingOnViewAppearance() {
        let viewController = AutomaticMockViewController()
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("automatic"))
            }
        ) {
            viewController.viewDidAppear(false)
        }
    }

    func testManualTracking() {
        let viewController = ManualMockViewController()
        expectNoEvents(during: .seconds(2)) {
            viewController.viewDidAppear(false)
        }
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("manual"))
            }
        ) {
            viewController.trackPageView()
        }
    }
}
