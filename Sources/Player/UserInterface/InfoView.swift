//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// Namespace grouping types related to info view actions in a tvOS player.
public enum InfoView {
    /// Defines the top action displayed in an info view.
    public struct Top {
        let action: InfoViewAction

        /// Creates a top action.
        ///
        /// - Parameter content: A closure returning the action to display.
        public init(@InfoViewActionBuilder _ content: () -> InfoViewAction) {
            self.action = content()
        }
    }

    /// Defines the bottom action displayed in an info view.
    public struct Bottom {
        let action: InfoViewAction

        /// Creates a bottom action.
        ///
        /// - Parameter content: A closure returning the action to display.
        public init(@InfoViewActionBuilder _ content: () -> InfoViewAction) {
            self.action = content()
        }
    }
}
