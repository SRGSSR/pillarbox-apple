//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that can be displayed as info view action.
public protocol InfoViewAction: UIInfoViewActionConvertible {}

/// A type that can be converted to an info view action.
public protocol UIInfoViewActionConvertible {
    /// Converts the type to an action.
    ///
    /// - Parameter viewController: The view controller to dismiss when executing the action.
    func toUIAction(dismissing viewController: UIViewController) -> UIAction
}
