//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// An inline menu displayed in a menu.
public struct InlineMenuInMenu: MenuElement {
    let title: String
    let children: [UIMenuElement]

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, identifier: .init(rawValue: title), options: [.displayInline], children: children)
    }
}

/// An inline menu displayed in a selection menu.
public struct InlineMenuInSelectionMenu: SelectionMenuElement {
    let title: String
    let children: [UIMenuElement]

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, identifier: .init(rawValue: title), options: [.displayInline], children: children)
    }
}

/// An inline menu.
public struct InlineMenu<Body> {
    private let body: Body
}

extension InlineMenu: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension InlineMenu: MenuElement where Body == InlineMenuInMenu {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, @InlineMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, @InlineMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameter content: The menu's content.
    public init(@InlineMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: "", children: content().children)
    }
}

extension InlineMenu: SelectionMenuElement where Body == InlineMenuInSelectionMenu {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, @InlineMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, @InlineMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameter content: The menu's content.
    public init(@InlineMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: "", children: content().children)
    }
}
