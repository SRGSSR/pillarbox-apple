//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A result builder that enables declarative construction of one or two `InfoViewAction`.
@resultBuilder
public enum InfoViewActionsBuilder {
    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ action: InfoViewAction) -> InfoViewAction {
        action
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ action: InfoViewAction?) -> [InfoViewAction] {
        if let action {
            [action]
        }
        else {
            []
        }
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ first: InfoViewAction?, _ second: InfoViewAction) -> [InfoViewAction] {
        [first, second].compactMap(\.self)
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ first: InfoViewAction, _ second: InfoViewAction?) -> [InfoViewAction] {
        [first, second].compactMap(\.self)
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ first: InfoViewAction?, _ second: InfoViewAction?) -> [InfoViewAction] {
        [first, second].compactMap(\.self)
    }

    // swiftlint:disable:next missing_docs
    public static func buildBlock(_ first: InfoViewAction, _ second: InfoViewAction) -> [InfoViewAction] {
        [first, second]
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither(first action: InfoViewAction) -> InfoViewAction {
        action
    }

    // swiftlint:disable:next missing_docs
    public static func buildEither(second action: InfoViewAction) -> InfoViewAction {
        action
    }

    // swiftlint:disable:next missing_docs
    public static func buildOptional(_ action: InfoViewAction?) -> InfoViewAction? {
        action
    }
}
