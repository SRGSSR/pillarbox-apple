//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative info view action construction.
@resultBuilder
public enum InfoViewActionsContentBuilder {
    /// Type of partial results.
    public typealias Component = [any InfoViewActionsElement]

    /// Type of the final result.
    public typealias Result = InfoViewActionsContent

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: any InfoViewActionsElement) -> Component {
        [expression]
    }

    @available(*, unavailable, message: "At most 2 items can be added to the info view actions")
    public static func buildBlock(_ components: Component...) -> Component {
        // swiftlint:disable:previous missing_docs
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock() -> Component {
        []
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
    public static func buildFinalResult(_ component: Component) -> Result {
        .init(children: component)
    }
}
