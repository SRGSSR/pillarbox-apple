//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol PageViewTracking {
    var pageTitle: String { get }
    var pageLevels: [String] { get }
    var isTrackedAutomatically: Bool { get }
}

public extension PageViewTracking {
    var pageLevels: [String] {
        []
    }

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
        if Bundle.main.infoDictionary?["UIApplicationSceneManifest"] != nil {
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

    private static func sendPageViews(in windowScene: UIWindowScene) {
        windowScene.windows.forEach { window in
            sendPageViews(in: window)
        }
    }

    private static func sendPageViews(in window: UIWindow) {
        var topViewController = window.rootViewController
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        topViewController?.sendPageView(automatic: true, recursive: true)
    }

    private static func children(in viewController: UIViewController) -> [UIViewController] {
        guard let containerViewController = viewController as? ContainerPageViewTracking else {
            return viewController.children
        }
        return containerViewController.activeChildren
    }

    @objc
    static func applicationWillEnterForeground(_ notification: Notification) {
        guard let application = notification.object as? UIApplication,
              let windowScene = application.connectedScenes.first as? UIWindowScene else {
            return
        }
        sendPageViews(in: windowScene)
    }

    @objc
    static func sceneWillEnterForeground(_ notification: Notification) {
        guard let windowScene = notification.object as? UIWindowScene else { return }
        sendPageViews(in: windowScene)
    }

    @objc
    func swizzledViewDidAppear(_ animated: Bool) {
        swizzledViewDidAppear(animated)
        sendPageView(automatic: true, recursive: false)
    }

    public func sendPageView() {
        sendPageView(automatic: false, recursive: false)
    }

    private func sendPageView(automatic: Bool, recursive: Bool) {
        if recursive {
            Self.children(in: self).forEach { viewController in
                viewController.sendPageView(automatic: automatic, recursive: true)
            }
        }
        guard let trackedViewController = self as? PageViewTracking,
              automatic, trackedViewController.isTrackedAutomatically else {
            return
        }
        Analytics.shared.sendPageView(title: trackedViewController.pageTitle, levels: trackedViewController.pageLevels)
    }

    public func setNeedsAutomaticPageViewTracking(in viewController: UIViewController) {
        guard Self.children(in: self).contains(viewController) else { return }
        viewController.sendPageView(automatic: true, recursive: true)
    }
}
