//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that contains info view actions.
public struct InfoViewActionsContent {
    let actions: [InfoViewAction]

    init(actions: [InfoViewAction] = []) {
        self.actions = actions
    }

    func toUIActions(dismissing viewController: UIViewController) -> [UIAction] {
        actions.map { $0.toUIAction(dismissing: viewController) }
    }
}
