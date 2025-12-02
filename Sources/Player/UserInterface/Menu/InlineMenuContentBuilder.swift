//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative inline menu construction.
@resultBuilder
public enum InlineMenuContentBuilder {
    /// Type of statement expressions.
    public typealias Expression = InlineMenuElement

    /// Type of partial results.
    public typealias Component = [Expression]

    /// Type of the final result.
    public typealias Result = MenuContent

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap(\.self)
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
    public static func buildFinalResult(_ component: Component) -> Result {
        .init(children: component.map { $0.toUIMenuElement() })
    }
}
