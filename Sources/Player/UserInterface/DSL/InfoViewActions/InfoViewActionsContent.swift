//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that describing the content of info view actions.
public struct InfoViewActionsContent {
    private let children: [any InfoViewActionsElement]

    init(children: [any InfoViewActionsElement] = []) {
        self.children = children
    }

    func toActions(dismissing viewController: UIViewController) -> [UIAction] {
        children.map { $0.toAction(dismissing: viewController) }
    }
}
