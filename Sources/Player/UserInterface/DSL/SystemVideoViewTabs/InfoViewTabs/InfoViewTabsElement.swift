//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A protocol adopted by elements displayable as info view tabs.
public protocol InfoViewTabsElement {
    /// A method that returns a view controller for the element, possibly reusing one from the provided list.
    /// - Parameter viewControllers: View controllers that can be reused.
    func viewController(reusing viewControllers: [UIViewController]) -> UIViewController
}
