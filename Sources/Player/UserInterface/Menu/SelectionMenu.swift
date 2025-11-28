//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct SelectionMenuInInlineMenu: InlineMenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), options: [.singleSelection], children: children)
    }
}

public struct SelectionMenuInMenu: MenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), options: [.singleSelection], children: children)
    }
}

public struct SelectionMenuInSelectionMenu: SelectionMenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), options: [.singleSelection], children: children)
    }
}

public struct SelectionMenuInTransportBar: TransportBarElement {
    let title: String
    let image: UIImage
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), options: [.singleSelection], children: children)
    }
}

public struct SelectionMenu<Body>: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    private let body: Body

    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension SelectionMenu: InlineMenuElement where Body == SelectionMenuInInlineMenu {
    public init(title: String, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, children: content().children)
    }
}

extension SelectionMenu: MenuElement where Body == SelectionMenuInMenu {
    public init(title: String, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, children: content().children)
    }
}

extension SelectionMenu: SelectionMenuElement where Body == SelectionMenuInSelectionMenu {
    public init(title: String, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, children: content().children)
    }
}

extension SelectionMenu: TransportBarElement where Body == SelectionMenuInTransportBar {
    public init(title: String, image: UIImage, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, children: content().children)
    }
}
