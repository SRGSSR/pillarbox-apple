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

private class CustomContainerViewController: UIViewController, ContainerPageViewTracking {
    private let viewControllers: [UIViewController]

    var activeChildren: [UIViewController] {
        if let firstViewController = viewControllers.first {
            return [firstViewController]
        }
        else {
            return []
        }
    }

    init(viewControllers: [UIViewController]) {
        self.viewControllers = viewControllers
        super.init(nibName: nil, bundle: nil)
        viewControllers.forEach { viewController in
            addChild(viewController)
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            viewController.simulateViewAppearance()
        }
    }

    func testManualTrackingWithoutProtocolImplementation() {
        let viewController = UIViewController()
        expectNoEvents(during: .seconds(2)) {
            viewController.trackPageView()
        }
    }

    func testAutomaticTrackingOnViewController() {
        let viewController = AutomaticMockViewController()
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("automatic"))
            }
        ) {
            viewController.simulateViewAppearance()
        }
    }

    func testSinglePageViewOnContainerAppearance() {
        let viewController = AutomaticMockViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        expectEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("automatic"))
            },
            during: .seconds(2)
        ) {
            navigationController.simulateViewAppearance()
            viewController.simulateViewAppearance()
        }
    }

    func testAutomaticTrackingOnViewAppearanceWhenActiveInParent() {
        let viewController1 = AutomaticMockViewController(title: "title1")
        let viewController2 = AutomaticMockViewController(title: "title2")
        _ = CustomContainerViewController(viewControllers: [viewController1, viewController2])
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("title1"))
            }
        ) {
            viewController1.simulateViewAppearance()
        }
    }

    func testAutomaticTrackingOnViewAppearanceWhenInactiveInParent() {
        let viewController1 = AutomaticMockViewController(title: "title1")
        let viewController2 = AutomaticMockViewController(title: "title2")
        _ = CustomContainerViewController(viewControllers: [viewController1, viewController2])
        expectNoEvents(during: .seconds(2)) {
            viewController2.simulateViewAppearance()
        }
    }

    func testAutomaticTrackingOnViewAppearanceWhenInActiveHierarchy() {
        let viewController1 = AutomaticMockViewController(title: "title1")
        let viewController2 = AutomaticMockViewController(title: "title2")
        _ = CustomContainerViewController(viewControllers: [
            UINavigationController(rootViewController: viewController1),
            UINavigationController(rootViewController: viewController2)
        ])
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("title1"))
            }
        ) {
            viewController1.simulateViewAppearance()
        }
    }

    func testAutomaticTrackingOnViewAppearanceWhenInInactiveHierarchy() {
        let viewController1 = AutomaticMockViewController(title: "title1")
        let viewController2 = AutomaticMockViewController(title: "title2")
        _ = CustomContainerViewController(viewControllers: [
            UINavigationController(rootViewController: viewController1),
            UINavigationController(rootViewController: viewController2)
        ])
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
                expect(labels.ns_category).to(equal("manual"))
            }
        ) {
            viewController.trackPageView()
        }
    }

    func testAutomaticTrackingFromViewController() {
        let viewController = AutomaticMockViewController()
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("automatic"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testAutomaticTrackingFromNavigationController() {
        let viewController = UINavigationController(rootViewController: AutomaticMockViewController(title: "root"))
        viewController.pushViewController(AutomaticMockViewController(title: "pushed"), animated: false)
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("pushed"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testAutomaticTrackingFromPageViewController() {
        let viewController = UIPageViewController()
        viewController.setViewControllers([AutomaticMockViewController(title: "title1")], direction: .forward, animated: false)
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("title1"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testAutomaticTrackingFromSplitViewController() {
        let viewController = UISplitViewController()
        viewController.viewControllers = [
            AutomaticMockViewController(title: "title1"),
            AutomaticMockViewController(title: "title2")
        ]
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("title1"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testAutomaticTrackingFromTabBarController() {
        let viewController = UITabBarController()
        viewController.viewControllers = [
            AutomaticMockViewController(title: "title1"),
            AutomaticMockViewController(title: "title2"),
            AutomaticMockViewController(title: "title3")
        ]
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("title1"))
            }
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testAutomaticTrackingFromCustomContainer() {
        let viewController = CustomContainerViewController(viewControllers: [
            AutomaticMockViewController(title: "title1"),
            AutomaticMockViewController(title: "title2")
        ])
        expectEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("title1"))
            },
            during: .seconds(2)
        ) {
            viewController.recursivelyTrackAutomaticPageViews()
        }
    }

    func testAutomaticTrackingInWindow() {
        let window = UIWindow()
        window.makeKeyAndVisible()
        window.rootViewController = AutomaticMockViewController()
        expectAtLeastEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("automatic"))
            }
        ) {
            window.recursivelyTrackAutomaticPageViews()
        }
    }

    func testAutomaticTrackingInWindowWithModalPresentation() {
        let window = UIWindow()
        let rootViewController = AutomaticMockViewController(title: "root")
        window.makeKeyAndVisible()
        window.rootViewController = rootViewController
        rootViewController.present(AutomaticMockViewController(title: "modal"), animated: false)
        expectEvents(
            .view { labels in
                expect(labels.ns_category).to(equal("modal"))
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
