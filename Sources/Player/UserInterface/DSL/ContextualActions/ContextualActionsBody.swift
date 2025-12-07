//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct ContextualActionsBodyNotSupported: ContextualActionsBody {
    // swiftlint:disable:next unavailable_function
    public func toAction() -> UIAction {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

public protocol ContextualActionsBody {
    func toAction() -> UIAction
}
