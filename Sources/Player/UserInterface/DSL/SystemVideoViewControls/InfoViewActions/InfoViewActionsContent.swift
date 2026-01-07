//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that describing the content of info view actions.
public struct InfoViewActionsContent {
    private let elements: [any InfoViewActionsElement]

    init(elements: [any InfoViewActionsElement] = []) {
        self.elements = elements
    }

    func toActions(dismissing viewController: UIViewController) -> [UIAction] {
        elements.map { $0.toAction(dismissing: viewController) }
    }
}
