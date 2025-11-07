//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative construction of multiple `InfoViewActions`.
@resultBuilder
public enum InfoViewActionsBuilder {
    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ components: [InfoViewActions]...) -> [InfoViewActions] {
        components.flatMap(\.self)
    }

    // swiftlint:disable:next missing_docs
    public static func buildExpression(_ expression: InfoViewActions) -> [InfoViewActions] {
        [expression]
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither(first component: [InfoViewActions]) -> [InfoViewActions] {
        component
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither(second component: [InfoViewActions]) -> [InfoViewActions] {
        component
    }
}
