//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A protocol that view controller containers can implement to declare how they are tracked.
///
/// View controllers whose usage must be measured should conform to the `PageViewTracking` protocol, which describes
/// the associated measurement data:
/// 
/// - Page title.
/// - Page levels.
///
/// The protocol also provides a `isTrackedAutomatically` property, set to `true` by default, which lets you choose
/// between automatic and manual tracking.
///
/// ### Automatic Tracking
///
/// In automatic mode a page view is automatically emitted for a `PageViewTracking`-conforming view controller when:
///
/// - Its `viewDidAppear(_:)` method is called.
/// - The application returns from background and the view controller is active (which in general means its is visible,
///   though this can depend on which container displays the view controller, see `ContainerPageViewTracking`).
///
/// ### Manual Tracking
///
/// If you need to precisely control when page view events are emitted you can implement the optional
/// `isTrackedAutomatically` property to return `false`. This is mostly useful when page view information is not
/// available at the time `viewDidAppear(_:)` is called, e.g. if this information is retrieved asynchronously. Beware
/// that in this case you are responsible of calling `UIViewController.trackPageView()` when:
///
/// - The view is visible and you received the information you needed for the page view.
/// - The application returns from background and the information you need for the page view is readily available.
///
/// ### Raw Page View Tracking
///
/// If you prefer you can also perform manual page view tracking using the corresponding methods available from
/// the `Analytics` singleton. You are in this case responsible of following the rules listed above in the same way.
///
/// ### Containers
///
/// If your application uses custom view controller containers, and if you want to use automatic tracking, be sure to
/// have them conform to the `ContainerPageViewTracking` protocol so that automatic page views are correctly propagated
/// through your application view controller hierarchy. Refer to `ContainerPageViewTracking` documentation for more
/// information.
public protocol PageViewTracking {
    /// The page view title.
    var pageTitle: String { get }

    /// The page view levels. Defaults to an empty array.
    var pageLevels: [String] { get }

    /// A Boolean to enable or disable automatic tracking. Defaults to `true`.
    var isTrackedAutomatically: Bool { get }
}

public extension PageViewTracking {
    /// The default page levels.
    var pageLevels: [String] {
        []
    }

    /// The default automatic tracking setting.
    var isTrackedAutomatically: Bool {
        true
    }
}

extension UIViewController {
    private var trackedChildren: [UIViewController] {
        guard let containerViewController = self as? ContainerPageViewTracking else { return children }
        return containerViewController.activeChildren
    }

    static func setupViewControllerTracking() {
        method_exchangeImplementations(
            class_getInstanceMethod(Self.self, #selector(viewDidAppear(_:)))!,
            class_getInstanceMethod(Self.self, #selector(swizzledViewDidAppear(_:)))!
        )

        // Scene support requires the `UIApplicationSceneManifest` key to be present in the Info.plist.
        if Bundle.main.infoDictionary?["UIApplicationSceneManifest"] == nil {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(applicationWillEnterForeground(_:)),
                name: UIApplication.willEnterForegroundNotification,
                object: nil
            )
        }
        else {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(sceneWillEnterForeground(_:)),
                name: UIScene.willEnterForegroundNotification,
                object: nil
            )
        }
    }

    private static func trackPageViews(in windowScene: UIWindowScene) {
    }

    @objc
    private static func applicationWillEnterForeground(_ notification: Notification) {
        guard let application = notification.object as? UIApplication,
              let windowScene = application.connectedScenes.first as? UIWindowScene else {
            return
        }
        trackPageViews(in: windowScene)
    }

    @objc
    private static func sceneWillEnterForeground(_ notification: Notification) {
        guard let windowScene = notification.object as? UIWindowScene else { return }
        trackPageViews(in: windowScene)
    }

    @objc
    private func swizzledViewDidAppear(_ animated: Bool) {
        swizzledViewDidAppear(animated)
        guard let trackedViewController = self as? PageViewTracking, trackedViewController.isTrackedAutomatically else { return }
        Analytics.shared.trackPageView(
            title: trackedViewController.pageTitle,
            levels: trackedViewController.pageLevels
        )
    }

    /// Perform manual page view tracking for the receiver, using data declared by `PageViewTracking` conformance.
    ///
    /// This method does nothing if the receiver does not conform to the `PageViewTracking` protocol and is mostly
    /// useful when automatic tracking has been disabled by setting `isTrackedAutomatically` to `false`.
    public func trackPageView() {
        guard let trackedViewController = self as? PageViewTracking else { return }
        Analytics.shared.trackPageView(
            title: trackedViewController.pageTitle,
            levels: trackedViewController.pageLevels
        )
    }
}
