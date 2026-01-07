//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative construction of custom info views for tvOS.
@resultBuilder
public enum InfoViewTabsContentBuilder {
    /// The type of individual statement.
    public typealias Expression = any InfoViewTabsElement

    /// Type of partial results.
    public typealias Component = [any InfoViewTabsElement]

    /// Type of the final result.
    public typealias Result = InfoViewTabsContent

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap(\.self)
    }

    // swiftlint:disable:next missing_docs
    public static func buildArray(_ components: [Component]) -> Component {
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
        .init(elements: component)
    }
}
