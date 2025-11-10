//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Namespace grouping types related to info view actions in a tvOS player.
public enum InfoView {
    /// Defines an action displayed in an info view.
    public struct Action {
        let action: InfoViewAction

        /// Creates an action.
        ///
        /// - Parameter content: A closure returning the action to display.
        public init(@InfoViewActionBuilder _ content: () -> InfoViewAction) {
            self.action = content()
        }
    }
}
