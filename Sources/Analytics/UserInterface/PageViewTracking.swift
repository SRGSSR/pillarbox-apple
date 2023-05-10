//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// View controllers whose usage must be measured should conform to the `PageViewTracking` protocol, which describes
/// the associated measurement data.
///
/// By default, if a view controller conforms to the `PageViewTracking` protocol, a page view event will automatically
/// be sent each time its `viewDidAppear(_:)` method is called. Page views are also sent when the application returns
/// from background automatically.
///
/// If you need to precisely control when page view events are emitted, however, you can implement the optional
/// `isTrackedAutomatically` property to return `false`, disabling both mechanisms described above. This is mostly
/// useful when page view information is not available at the time `viewDidAppear(_:)` is called, e.g. if this
/// information is retrieved from a web service request. Beware that in this case you are responsible of calling
/// `UIViewController.sendPageView()` when:
///
///   - The view is visible and you received the information you needed for the page view.
///   - The application returns from background and the information you need for the page view is readily available.
///
/// If you prefer you can also perform manual page view tracking using the corresponding methods available from
/// the `Analytics` singleton. You are in this case responsible of following the rules listed above in the same way.
///
/// If your application uses custom view controller containers, and if you want to use automatic tracking, be sure to
/// have them conform to the `ContainerPageViewTracking` protocol so that automatic page views are correctly propagated
/// through your application view controller hierarchy. If a view controller does not implement this protocol but
/// contains children, page view events will be propagated to all of them by default.
public protocol PageViewTracking {
    /// The page view title.
    var pageTitle: String { get }

    /// The page view levels. Defaults to an empty array.
    var pageLevels: [String] { get }

    /// Whether automatic tracking is enabled. Defaults to `true`.
    var isTrackedAutomatically: Bool { get }
}

public extension PageViewTracking {
    /// Default page levels.
    var pageLevels: [String] { [] }

    /// Default automatic tracking setting.
    var isTrackedAutomatically: Bool { true }
}

extension UIViewController {
    private var trackedChildren: [UIViewController] {
        guard let containerViewController = self as? ContainerPageViewTracking else {
            return children
        }
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

    @objc
    private static func applicationWillEnterForeground(_ notification: Notification) {
        guard let application = notification.object as? UIApplication,
              let windowScene = application.connectedScenes.first as? UIWindowScene else {
            return
        }
        sendPageViews(in: windowScene)
    }

    @objc
    private static func sceneWillEnterForeground(_ notification: Notification) {
        guard let windowScene = notification.object as? UIWindowScene else { return }
        sendPageViews(in: windowScene)
    }

    @objc
    private func swizzledViewDidAppear(_ animated: Bool) {
        swizzledViewDidAppear(animated)
        sendPageView(automatic: true, recursive: false)
    }

    /// Call this method to send a page view event manually for the receiver, using data declared by `PageViewTracking`
    /// conformance. This method does nothing if the receiver does not conform to the `PageViewTracking` protocol and
    /// is mostly useful when automatic tracking has been disabled.
    public func sendPageView() {
        sendPageView(automatic: false, recursive: false)
    }

    private func sendPageView(automatic: Bool, recursive: Bool) {
        if recursive {
            trackedChildren.forEach { viewController in
                viewController.sendPageView(automatic: automatic, recursive: true)
            }
        }
        guard let trackedViewController = self as? PageViewTracking,
              automatic, trackedViewController.isTrackedAutomatically else {
            return
        }
        Analytics.shared.sendPageView(title: trackedViewController.pageTitle, levels: trackedViewController.pageLevels)
    }

    /// Call this method after a child view controller has been added to a container to inform the automatic page view
    /// tracking engine that automatic page view event generation should be evaluated again.
    ///
    /// This method has no effect if the receiver does not conform to `ContainerPageViewTracking` or if the specified
    /// view controller is not a child of the receiver.
    ///
    /// This method is useful when implementing custom view controller containers displaying sibling view controllers,
    /// keeping them alive while inactive (custom tab bar controllers, for example). For containers hiding children
    /// which have disappeared (similarly to what navigation controllers do), calling this method is not required, as
    /// standard view appearance namely suffices to trigger automatic page views again when required.
    ///
    /// - Parameter viewController: The view controller for which automatic page view event generation must be
    ///   evaluated again.
    public func setNeedsAutomaticPageViewTracking(in viewController: UIViewController) {
        guard trackedChildren.contains(viewController) else { return }
        viewController.sendPageView(automatic: true, recursive: true)
    }
}
