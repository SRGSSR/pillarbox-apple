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

public struct InlineMenuInTransportBar: TransportBarElement {
    let title: String
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, identifier: .init(rawValue: title), options: [.displayInline], children: children)
    }
}

public struct InlineMenu<Body>: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    private let body: Body

    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension InlineMenu: MenuElement where Body == InlineMenuInMenu {
    public init(title: String = "", @InlineMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, children: content().children)
    }
}

extension InlineMenu: SelectionMenuElement where Body == InlineMenuInSelectionMenu {
    public init(title: String = "", @InlineMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, children: content().children)
    }
}

extension InlineMenu: TransportBarElement where Body == InlineMenuInTransportBar {
    public init(title: String = "", @InlineMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, children: content().children)
    }
}
