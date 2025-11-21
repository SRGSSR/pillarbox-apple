//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative construction of one or two `InfoViewAction`.
@resultBuilder
public enum SystemVideoViewActionsContentBuilder {
    /// Type of a statement expression.
    public typealias Expression = SystemVideoViewAction

    /// Type of a partial result.
    public typealias Component = [SystemVideoViewAction]

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ component: Component) -> Component {
        component
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ c0: Component, _ c1: Component) -> Component {
        c0 + c1
    }

    // swiftlint:disable:next missing_docs
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither(first component: Component) -> Component {
        component
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither(second component: Component) -> Component {
        component
    }

    // swiftlint:disable:next missing_docs
    public static func buildFinalResult(_ component: Component) -> SystemVideoViewActionsContent {
        .init(actions: component)
    }
}
