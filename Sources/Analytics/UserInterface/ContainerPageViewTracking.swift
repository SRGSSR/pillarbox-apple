//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A protocol that view controller containers can implement to customize automatic page view tracking.
///
/// Automatic page view tracking can be optionally adopted by view controllers, as described in `PageViewTracking`
/// documentation.
///
/// When containers are involved, though, which children view controller events should be automatically propagated to
/// must be correctly configured depending on the container type:
///
/// - If page views must be automatically forwarded to all children no additional work is required.
/// - If page views must be automatically forwarded to only selected children then a container must implement the
///   `ContainerPageViewTracking` protocol to declare which ones of its children must be considered active for
///   propagation.
///
/// ### Native UIKit Container Support
///
/// Some standard UIKit containers conform to `ContainerPageViewTracking` to implement correct propagation:
///
/// - `UINavigationController`: The top view controller is active.
/// - `UIPageViewController`: The currently visible view controller is active.
/// - `UISplitViewController`: The view controllers returned by `UISplitViewController.viewControllers` are active.
/// - `UITabBarController`: The currently visible view controller is active.
///
/// Other UIKit containers do not need to conform to `ContainerPageViewTracking` as default event propagation yields
/// correct behavior for them.
public protocol ContainerPageViewTracking: UIViewController {
    /// The list of currently active children in the view controller container.
    var activeChildren: [UIViewController] { get }
}

extension UINavigationController: ContainerPageViewTracking {
    public var activeChildren: [UIViewController] {
        guard let topViewController else { return [] }
        return [topViewController]
    }
}

extension UIPageViewController: ContainerPageViewTracking {
    public var activeChildren: [UIViewController] {
        guard let viewController = viewControllers?.first else { return [] }
        return [viewController]
    }
}

extension UISplitViewController: ContainerPageViewTracking {
    public var activeChildren: [UIViewController] {
        viewControllers
    }
}

extension UITabBarController: ContainerPageViewTracking {
    public var activeChildren: [UIViewController] {
        guard let selectedViewController else { return [] }
        return [selectedViewController]
    }
}
