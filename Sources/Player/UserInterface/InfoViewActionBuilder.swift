//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative creation of a single `InfoViewAction`.
///
/// ```swift
/// InfoView.Top {
///     .custom(title: "Watch Later", image: UIImage(systemName: "eyeglasses")) {
///         print("Watch Later tapped")
///     }
/// }
/// ```
@resultBuilder
public enum InfoViewActionBuilder {
    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ components: InfoViewAction...) -> InfoViewAction {
        components.first ?? .none
    }

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: InfoViewAction) -> InfoViewAction {
        expression
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither(first component: InfoViewAction) -> InfoViewAction {
        component
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither(second component: InfoViewAction) -> InfoViewAction {
        component
    }
}
