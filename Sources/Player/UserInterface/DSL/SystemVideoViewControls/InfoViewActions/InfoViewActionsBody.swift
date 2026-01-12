//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A body for elements not supporting wrapping in info view actions.
public struct InfoViewActionsBodyNotSupported: InfoViewActionsBody {
    // swiftlint:disable:next missing_docs unavailable_function
    public func toAction(dismissing viewController: UIViewController) -> UIAction {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

/// A protocol describing the body of elements wrapped in info view actions.
public protocol InfoViewActionsBody {
    /// Converts the body to an action.
    /// 
    /// - Parameter viewController: The view controller to dismiss when triggering the action.
    func toAction(dismissing viewController: UIViewController) -> UIAction
}
