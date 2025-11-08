//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative construction of `InfoViewActions`.
///
/// ```swift
/// InfoViewActions {
///     InfoView.Top {
///         .custom(title: "Watch Later", image: UIImage(systemName: "eyeglasses")) {
///             print("Watch Later")
///         }
///     }
///     InfoView.Bottom {
///         .system
///     }
/// }
/// ```
@resultBuilder
public enum InfoViewActionsBuilder {
    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ components: Any...) -> InfoViewActions {
        let top = components.compactMap { $0 as? InfoView.Top }.last
        let bottom = components.compactMap { $0 as? InfoView.Bottom }.last
        return InfoViewActions(top: top?.action ?? .none, bottom: bottom?.action ?? .none)
    }

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: InfoView.Top) -> InfoView.Top {
        expression
    }

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: InfoView.Bottom) -> InfoView.Bottom {
        expression
    }
}
