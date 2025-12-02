//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct InlineMenuInMenu: MenuElement {
    let title: String
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, identifier: .init(rawValue: title), options: [.displayInline], children: children)
    }
}

public struct InlineMenuInSelectionMenu: SelectionMenuElement {
    let title: String
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, identifier: .init(rawValue: title), options: [.displayInline], children: children)
    }
}

public struct InlineMenu<Body> {
    private let body: Body
}

extension InlineMenu: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension InlineMenu: MenuElement where Body == InlineMenuInMenu {
    @_disfavoredOverload
    public init<S>(title: S, @InlineMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), children: content().children)
    }

    public init(title: LocalizedStringResource, @InlineMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), content: content)
    }

    public init(@InlineMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: "", children: content().children)
    }
}

extension InlineMenu: SelectionMenuElement where Body == InlineMenuInSelectionMenu {
    @_disfavoredOverload
    public init<S>(title: S, @InlineMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), children: content().children)
    }

    public init(title: LocalizedStringResource, @InlineMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), content: content)
    }

    public init(@InlineMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: "", children: content().children)
    }
}
