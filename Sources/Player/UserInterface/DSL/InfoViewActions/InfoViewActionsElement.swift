//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A protocol adopted by elements displayable in info view actions.
public protocol InfoViewActionsElement {
    /// The body type.
    associatedtype Body: InfoViewActionsBody

    /// The body.
    var body: Body { get }
}

extension InfoViewActionsElement {
    func toAction(dismissing viewController: UIViewController) -> UIAction {
        body.toAction(dismissing: viewController)
    }
}
