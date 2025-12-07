//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A protocol adopted by elements displayable in contextual actions.
public protocol ContextualActionsElement {
    /// The body type.
    associatedtype Body: ContextualActionsBody

    /// The body.
    var body: Body { get }
}

extension ContextualActionsElement {
    func toAction() -> UIAction {
        body.toAction()
    }
}
