//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative construction of `InfoViewActions`.
///
/// ```swift
/// InfoViewActions {
///     InfoView.Action {
///         .custom(title: "Watch Later", image: UIImage(systemName: "eyeglasses")) {
///             print("Watch Later")
///         }
///     }
///     InfoView.Action {
///         .system
///     }
/// }
/// ```
@resultBuilder
public enum InfoViewActionsBuilder {
    // swiftlint:disable:next missing_docs
    public static func buildBlock() -> [InfoViewAction] {
        []
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ first: InfoView.Action) -> [InfoViewAction] {
        [first.action]
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ first: InfoView.Action, _ second: InfoView.Action) -> [InfoViewAction] {
        [first.action, second.action]
    }

    public static func buildOptional(_ component: [InfoViewAction]?) -> [InfoViewAction] {
        component ?? []
    }
}
