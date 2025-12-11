//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A body for elements not supporting wrapping in contextual actions.
public struct ContextualActionsBodyNotSupported: ContextualActionsBody {
    // swiftlint:disable:next missing_docs unavailable_function
    public func toAction() -> UIAction {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

/// A protocol describing the body of elements wrapped in contextual actions.
public protocol ContextualActionsBody {
    /// Converts the body to an action.
    func toAction() -> UIAction
}
