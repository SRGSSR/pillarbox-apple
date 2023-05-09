//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

extension UIViewController {
    static func setupTracking() {
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
        topViewController?.sendPageView(recursive: true)
    }

    private static func children(in viewController: UIViewController) -> [UIViewController] {
        guard let containerViewController = viewController as? ContainerPageViewTracking else {
            return viewController.children
        }
        return containerViewController.activeChildren
    }

    @objc static func applicationWillEnterForeground(_ notification: Notification) {
        guard let application = notification.object as? UIApplication,
              let windowScene = application.connectedScenes.first as? UIWindowScene else {
            return
        }
        sendPageViews(in: windowScene)
    }

    @objc static func sceneWillEnterForeground(_ notification: Notification) {
        guard let windowScene = notification.object as? UIWindowScene else { return }
        sendPageViews(in: windowScene)
    }

    @objc func swizzledViewDidAppear(_ animated: Bool) {
        swizzledViewDidAppear(animated)
        sendPageView(recursive: false)
    }

    private func sendPageView(recursive: Bool) {
        if recursive {
            Self.children(in: self).forEach { viewController in
                viewController.sendPageView(recursive: true)
            }
        }
        guard let trackedViewController = self as? PageViewTracking, trackedViewController.isTrackedAutomatically else { return }
        Analytics.shared.sendPageView(title: trackedViewController.pageTitle, levels: trackedViewController.pageLevels)
    }
}

extension UINavigationController: ContainerPageViewTracking {
    public var activeChildren: [UIViewController] {
        guard let topViewController else { return [] }
        return [topViewController]
    }
}
