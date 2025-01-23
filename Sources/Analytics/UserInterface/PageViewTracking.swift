//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A protocol that view controller containers can implement to declare how they are tracked.
///
/// View controllers whose usage must be measured should conform to the `PageViewTracking` protocol, which describes
/// the associated measurement data.
///
/// For more information please read the <doc:page-views-article> article.
public protocol PageViewTracking {
    /// The Commanders Act page view data.
    var commandersActPageView: CommandersActPageView { get }

    /// A Boolean to enable or disable automatic tracking. Defaults to `true`.
    var isTrackedAutomatically: Bool { get }
}

public extension PageViewTracking {
    /// The default automatic tracking setting.
    var isTrackedAutomatically: Bool {
        true
    }
}

extension UIViewController {
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

    @objc
    private static func applicationWillEnterForeground(_ notification: Notification) {
        guard let application = notification.object as? UIApplication,
              let windowScene = application.connectedScenes.first as? UIWindowScene else {
            return
        }
        windowScene.recursivelyTrackAutomaticPageViews()
    }

    @objc
    private static func sceneWillEnterForeground(_ notification: Notification) {
        guard let windowScene = notification.object as? UIWindowScene else { return }
        windowScene.recursivelyTrackAutomaticPageViews()
    }

    @objc
    private func swizzledViewDidAppear(_ animated: Bool) {
        swizzledViewDidAppear(animated)
        if isActive {
            trackAutomaticPageView()
        }
    }

    /// Perform manual page view tracking for the receiver, using data declared by `PageViewTracking` conformance.
    ///
    /// This method does nothing if the receiver does not conform to the `PageViewTracking` protocol and is mostly
    /// useful when automatic tracking has been disabled by setting `isTrackedAutomatically` to `false`.
    public func trackPageView() {
        guard let trackedViewController = self as? PageViewTracking else { return }
        Analytics.shared.trackPageView(commandersAct: trackedViewController.commandersActPageView)
    }
}

extension UIViewController {
    var isActive: Bool {
        guard let parent else { return true }
        return parent.effectivelyActiveChildren.contains(self) && parent.isActive
    }

    private var effectivelyActiveChildren: [UIViewController] {
        (self as? ContainerPageViewTracking)?.activeChildren ?? children
    }

    func trackAutomaticPageView() {
        guard let trackedViewController = self as? PageViewTracking, trackedViewController.isTrackedAutomatically else { return }
        Analytics.shared.trackPageView(commandersAct: trackedViewController.commandersActPageView)
    }

    func recursivelyTrackAutomaticPageViews() {
        effectivelyActiveChildren.forEach { viewController in
            viewController.recursivelyTrackAutomaticPageViews()
        }
        trackAutomaticPageView()
    }
}

extension UIWindow {
    func recursivelyTrackAutomaticPageViews() {
        var topViewController = rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        topViewController?.recursivelyTrackAutomaticPageViews()
    }
}

private extension UIWindowScene {
    func recursivelyTrackAutomaticPageViews() {
        windows.forEach { window in
            window.recursivelyTrackAutomaticPageViews()
        }
    }
}
