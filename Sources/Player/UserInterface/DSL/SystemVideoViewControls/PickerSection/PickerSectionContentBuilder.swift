//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative picker section construction.
@resultBuilder
public enum PickerSectionContentBuilder<Value> {
    /// Type of partial results.
    public typealias Component = [any PickerSectionElement<Value>]

    /// Type of the final result.
    public typealias Result = PickerSectionContent<Value>

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: any PickerSectionElement<Value>) -> Component {
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
    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap(\.self)
    }

    // swiftlint:disable:next missing_docs
    public static func buildFinalResult(_ component: Component) -> Result {
        .init(children: component)
    }
}
