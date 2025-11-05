//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Defines the available configurations for the actions displayed in an info view.
public enum InfoViewActions {
    /// Applies the default system behavior.
    case system

    /// No actions are displayed.
    case empty

    /// Displays a first action.
    case first(action: InfoViewAction)

    /// Displays a last action.
    case last(action: InfoViewAction)

    /// Displays two actions.
    case pair(firstAction: InfoViewAction, lastAction: InfoViewAction)
}
