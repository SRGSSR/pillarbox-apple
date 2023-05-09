//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol ContainerPageViewTracking {
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

// TODO: Maybe not necessary if children == viewControllers?
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
