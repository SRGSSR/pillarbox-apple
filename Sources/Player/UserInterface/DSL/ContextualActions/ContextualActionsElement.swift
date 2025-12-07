//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol ContextualActionsElement {
    associatedtype Body: ContextualActionsBody

    var body: Body { get }
}

extension ContextualActionsElement {
    func toAction() -> UIAction {
        body.toAction()
    }
}
