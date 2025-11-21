//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative construction of one up to two `SystemVideoViewAction`s.
@resultBuilder
public enum SystemVideoViewActionsContentBuilder2 {
    /// Type of a statement expression.
    public typealias Expression = SystemVideoViewAction

    /// Type of a partial result.
    public typealias Component = [SystemVideoViewAction]

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ c0: Component) -> Component {
        c0
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

/// A result builder that enables declarative construction of one up to seven `SystemVideoViewAction`s.
@resultBuilder
public enum SystemVideoViewActionsContentBuilder7 {
    /// Type of a statement expression.
    public typealias Expression = SystemVideoViewAction

    /// Type of a partial result.
    public typealias Component = [SystemVideoViewAction]

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ c0: Component) -> Component {
        c0
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ c0: Component, _ c1: Component) -> Component {
        c0 + c1
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ c0: Component, _ c1: Component, _ c2: Component) -> Component {
        c0 + c1 + c2
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ c0: Component, _ c1: Component, _ c2: Component, _ c3: Component) -> Component {
        c0 + c1 + c2 + c3
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ c0: Component, _ c1: Component, _ c2: Component, _ c3: Component, _ c4: Component) -> Component {
        c0 + c1 + c2 + c3 + c4
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ c0: Component, _ c1: Component, _ c2: Component, _ c3: Component, _ c4: Component, _ c5: Component) -> Component {
        c0 + c1 + c2 + c3 + c4 + c5
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ c0: Component, _ c1: Component, _ c2: Component, _ c3: Component, _ c4: Component, _ c5: Component, _ c6: Component) -> Component {
        c0 + c1 + c2 + c3 + c4 + c5 + c6
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
