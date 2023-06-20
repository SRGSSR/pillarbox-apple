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
        title ?? "automatic"
    }

    init(title: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
                expect(labels.c8).to(equal("title"))
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
            viewController.simulateViewAppearance()
        }
    }

    func testManualTrackingWithoutProtocolImplementation() {
        let viewController = UIViewController()
        expectNoEvents(during: .seconds(2)) {
            viewController.trackPageView()
        }
    }

    func testAutomaticTrackingWhenViewAppears() {
        let viewController = AutomaticMockViewController()
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("automatic"))
            }
        ) {
            viewController.simulateViewAppearance()
        }
    }

    func testSinglePageViewWhenContainerViewAppears() {
        let viewController = AutomaticMockViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        expectEvents(
            .view { labels in
                expect(labels.c8).to(equal("automatic"))
            },
            during: .seconds(2)
        ) {
            navigationController.simulateViewAppearance()
            viewController.simulateViewAppearance()
        }
    }

    func testAutomaticTrackingWhenActiveViewInParentAppears() {
        let viewController1 = AutomaticMockViewController(title: "title1")
        let viewController2 = AutomaticMockViewController(title: "title2")
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [viewController1, viewController2]
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("title1"))
            }
        ) {
            viewController1.simulateViewAppearance()
        }
    }

    func testAutomaticTrackingWhenInactiveViewInParentAppears() {
        let viewController1 = AutomaticMockViewController(title: "title1")
        let viewController2 = AutomaticMockViewController(title: "title2")
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [viewController1, viewController2]
        expectNoEvents(during: .seconds(2)) {
            viewController2.simulateViewAppearance()
        }
    }

    func testAutomaticTrackingWhenViewAppearsInActiveHierarchy() {
        let viewController1 = AutomaticMockViewController(title: "title1")
        let viewController2 = AutomaticMockViewController(title: "title2")
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: viewController1),
            UINavigationController(rootViewController: viewController2)
        ]
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("title1"))
            }
        ) {
            viewController1.simulateViewAppearance()
        }
    }

    func testAutomaticTrackingWhenViewAppearsInInactiveHierarchy() {
        let viewController1 = AutomaticMockViewController(title: "title1")
        let viewController2 = AutomaticMockViewController(title: "title2")
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [
            UINavigationController(rootViewController: viewController1),
            UINavigationController(rootViewController: viewController2)
        ]
        expectNoEvents(during: .seconds(2)) {
            viewController2.simulateViewAppearance()
        }
    }

    func testManualTracking() {
        let viewController = ManualMockViewController()
        expectNoEvents(during: .seconds(2)) {
            viewController.simulateViewAppearance()
        }
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("manual"))
            }
        ) {
            viewController.trackPageView()
        }
    }

    func testRecursiveAutomaticTrackingOnViewController() {
        let viewController = AutomaticMockViewController()
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("automatic"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testRecursiveAutomaticTrackingOnNavigationController() {
        let viewController = UINavigationController(rootViewController: AutomaticMockViewController(title: "root"))
        viewController.pushViewController(AutomaticMockViewController(title: "pushed"), animated: false)
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("pushed"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testRecursiveAutomaticTrackingOnPageViewController() {
        let viewController = UIPageViewController()
        viewController.setViewControllers([AutomaticMockViewController()], direction: .forward, animated: false)
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("automatic"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testRecursiveAutomaticTrackingOnSplitViewController() {
        let viewController = UISplitViewController()
        viewController.viewControllers = [
            AutomaticMockViewController(title: "title1"),
            AutomaticMockViewController(title: "title2")
        ]
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("title1"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testRecursiveAutomaticTrackingOnTabBarController() {
        let viewController = UITabBarController()
        viewController.viewControllers = [
            AutomaticMockViewController(title: "title1"),
            AutomaticMockViewController(title: "title2"),
            AutomaticMockViewController(title: "title3")
        ]
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("title1"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testRecursiveAutomaticTrackingOnWindow() {
        let window = UIWindow()
        window.makeKeyAndVisible()
        window.rootViewController = AutomaticMockViewController()
        expectAtLeastEvents(
            .view { labels in
                expect(labels.c8).to(equal("automatic"))
            }
        ) {
            window.recursivelyTrackAutomaticPageViews()
        }
    }

    func testRecursiveAutomaticTrackingOnWindowWithModalPresentation() {
        let window = UIWindow()
        let rootViewController = AutomaticMockViewController(title: "root")
        window.makeKeyAndVisible()
        window.rootViewController = rootViewController
        rootViewController.present(AutomaticMockViewController(title: "modal"), animated: false)
        expectEvents(
            .view { labels in
                expect(labels.c8).to(equal("modal"))
            },
            during: .seconds(2)
        ) {
            window.recursivelyTrackAutomaticPageViews()
        }
    }
}

private extension UIViewController {
    func simulateViewAppearance() {
        beginAppearanceTransition(true, animated: false)
        endAppearanceTransition()
    }
}
