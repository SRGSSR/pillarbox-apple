//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct InfoViewActionsBodyNotSupported: InfoViewActionsBody {
    // swiftlint:disable:next unavailable_function
    public func toAction(dismissing viewController: UIViewController) -> UIAction {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

public protocol InfoViewActionsBody {
    func toAction(dismissing viewController: UIViewController) -> UIAction
}
