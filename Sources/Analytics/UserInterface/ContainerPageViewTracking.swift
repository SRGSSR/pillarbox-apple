//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// Protocol for custom containers to implement automatic page view tracking propagation to their children. Standard
/// UIKit containers already conform to this protocol and do not require any additional work. Custom containers
/// should conform to this protocol to precisely declare which ones of their children are visible. If the protocol
/// is not implemented all its children are considered to be visible.
///
/// The implementation of a custom container might also need to inform the automatic page view tracking engine of
/// child controller appearance, see `UIViewController.setNeedsAutomaticPageViewTracking(in:)` documentation for
/// more information.
public protocol ContainerPageViewTracking {
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

    static func setupTabBarControllerTracking() {
        method_exchangeImplementations(
            class_getInstanceMethod(Self.self, #selector(setter: selectedViewController))!,
            class_getInstanceMethod(Self.self, #selector(swizzledSetSelectedViewController(_:)))!
        )
    }

    @objc
    public func swizzledSetSelectedViewController(_ viewController: UIViewController) {
        let changed = (viewController !== self.selectedViewController)
        swizzledSetSelectedViewController(viewController)
        if changed {
            setNeedsAutomaticPageViewTracking(in: viewController)
        }
    }
}
