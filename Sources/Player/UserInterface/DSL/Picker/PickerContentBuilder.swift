//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative picker construction.
@resultBuilder
public enum PickerContentBuilder<Value> {
    /// Type of partial results.
    public typealias Component = [any PickerElement<Value>]

    /// Type of the final result.
    public typealias Result = PickerContent<Value>

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: any PickerElement<Value>) -> Component {
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
