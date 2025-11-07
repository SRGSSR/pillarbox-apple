//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// Defines the available configurations for the actions displayed in an info view.
public enum InfoViewActions {
    /// Applies the default system action.
    case system

    /// Displays no action in the info view.
    case empty

    /// Displays a custom action in the info view.
    case action(InfoViewAction)
}

public extension InfoViewActions {
    /// This is a convenience helper that avoids the need to directly initialize
    /// an `InfoViewAction` using `.init`.
    static func action(title: String, image: UIImage? = nil, handler: @escaping () -> Void) -> Self {
        .action(.init(title: title, image: image, handler: handler))
    }
}

extension Array where Element == InfoViewActions {
    // swiftlint:disable:next cyclomatic_complexity
    func toUIActions(using defaultSystemActions: [UIAction]) -> [UIAction] {
        var actions: [UIAction] = []
        if let topAction = first {
            switch topAction {
            case .system:
                if let firstAction = defaultSystemActions.first {
                    actions = [firstAction]
                }
            case .empty:
                actions = []
            case let .action(infoViewAction):
                actions = [infoViewAction.toUIAction()]
            }
        }
        if let bottomAction = last, count > 1 {
            switch bottomAction {
            case .system:
                if let lastAction = defaultSystemActions.last {
                    actions.append(lastAction)
                }
            case .empty:
                actions.removeLast()
            case let .action(infoViewAction):
                actions.append(infoViewAction.toUIAction())
            }
        }
        return actions
    }
}
