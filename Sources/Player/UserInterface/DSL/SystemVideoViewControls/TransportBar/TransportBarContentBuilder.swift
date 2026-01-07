//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative transport bar construction.
@resultBuilder
public enum TransportBarContentBuilder {
    /// Type of partial results.
    public typealias Component = [any TransportBarElement]

    /// Type of the final result.
    public typealias Result = TransportBarContent

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: any TransportBarElement) -> Component {
        [expression]
    }

    @available(*, unavailable, message: "At most 7 items can be added to the transport bar")
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
    public static func buildBlock(
        _ c0: Component,
        _ c1: Component,
        _ c2: Component,
        _ c3: Component,
        _ c4: Component,
        _ c5: Component,
        _ c6: Component
    ) -> Component {
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
    public static func buildFinalResult(_ component: Component) -> Result {
        .init(children: component)
    }
}
