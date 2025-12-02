//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that contains contextual actions.
public struct ContextualActionsContent {
    let actions: [ContextualAction]

    init(actions: [ContextualAction] = []) {
        self.actions = actions
    }

    func toUIActions() -> [UIAction] {
        actions.map { $0.toUIAction() }
    }
}
