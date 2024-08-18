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
/// For more information please read the <doc:page-views-article> article.
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
