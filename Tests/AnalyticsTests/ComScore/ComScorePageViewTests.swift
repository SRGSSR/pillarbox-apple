//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Analytics

import Circumspect
import Nimble
import UIKit
import XCTest

private class AutomaticMockViewController: UIViewController, PageViewTracking {
    private var pageTitle: String {
        title ?? "automatic"
    }

    var comScorePageView: ComScorePageView {
        .init(title: pageTitle)
    }

    var commandersActPageView: CommandersActPageView {
        .init(title: pageTitle, type: "type")
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
    private var pageTitle: String {
        "automatic_with_levels"
    }

    var comScorePageView: ComScorePageView {
        .init(title: pageTitle)
    }

    var commandersActPageView: CommandersActPageView {
        .init(title: pageTitle, type: "type", levels: ["level1", "level2"])
    }
}

private class ManualMockViewController: UIViewController, PageViewTracking {
    private var pageTitle: String {
        "manual"
    }

    var comScorePageView: ComScorePageView {
        .init(title: pageTitle)
    }

    var commandersActPageView: CommandersActPageView {
        .init(title: pageTitle, type: "type")
    }

    var isTrackedAutomatically: Bool {
        false
    }
}

final class ComScorePageViewTests: ComScoreTestCase {
    func testLabels() {
        expectAtLeastHits(
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
            Analytics.shared.trackPageView(
                comScore: .init(title: "title"),
                commandersAct: .init(title: "title", type: "type")
            )
        }
    }

    func testBlankTitle() {
        guard nimbleThrowAssertionsAvailable() else { return }
        expect(Analytics.shared.trackPageView(
            comScore: .init(title: " "),
            commandersAct: .init(title: "title", type: "type")
        )).to(throwAssertion())
    }

    func testCustomLabels() {
        expectAtLeastHits(
            .view { labels in
                expect(labels["key"]).to(equal("value"))
            }
        ) {
            Analytics.shared.trackPageView(
                comScore: .init(title: "title", labels: ["key": "value"]),
                commandersAct: .init(title: "title", type: "type")
            )
        }
    }

    func testCustomLabelsForbiddenOverrides() {
        expectAtLeastHits(
            .view { labels in
                expect(labels.c8).to(equal("title"))
            }
        ) {
            Analytics.shared.trackPageView(
                comScore: .init(title: "title", labels: ["c8": "overridden_title"]),
                commandersAct: .init(title: "title", type: "type")
            )
        }
    }

    func testDefaultProtocolImplementation() {
        let viewController = AutomaticMockViewController()
        expect(viewController.isTrackedAutomatically).to(beTrue())
    }

    func testCustomProtocolImplementation() {
        let viewController = ManualMockViewController()
        expect(viewController.isTrackedAutomatically).to(beFalse())
    }

    func testAutomaticTrackingWithoutProtocolImplementation() {
        let viewController = UIViewController()
        expectNoHits(during: .seconds(2)) {
            viewController.simulateViewAppearance()
        }
    }

    func testManualTrackingWithoutProtocolImplementation() {
        let viewController = UIViewController()
        expectNoHits(during: .seconds(2)) {
            viewController.trackPageView()
        }
    }

    func testAutomaticTrackingWhenViewAppears() {
        let viewController = AutomaticMockViewController()
        expectAtLeastHits(
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
        expectHits(
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
        expectAtLeastHits(
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
        expectNoHits(during: .seconds(2)) {
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
        expectAtLeastHits(
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
        expectNoHits(during: .seconds(2)) {
            viewController2.simulateViewAppearance()
        }
    }

    func testManualTracking() {
        let viewController = ManualMockViewController()
        expectNoHits(during: .seconds(2)) {
            viewController.simulateViewAppearance()
        }
        expectAtLeastHits(
            .view { labels in
                expect(labels.c8).to(equal("manual"))
            }
        ) {
            viewController.trackPageView()
        }
    }

    func testRecursiveAutomaticTrackingOnViewController() {
        let viewController = AutomaticMockViewController()
        expectAtLeastHits(
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
        expectAtLeastHits(
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
        expectAtLeastHits(
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
        expectAtLeastHits(
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
        expectAtLeastHits(
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
        expectAtLeastHits(
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
        expectHits(
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
