//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct MenuInInlineMenu: InlineMenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), children: children)
    }
}

public struct MenuInMenu: MenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), children: children)
    }
}

public struct MenuInTransportBar: TransportBarElement {
    let title: String
    let image: UIImage
    let children: [UIMenuElement]

    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), children: children)
    }
}

public struct Menu<Body> {
    private let body: Body
}

extension Menu: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension Menu: InlineMenuElement where Body == MenuInInlineMenu {
    public init(title: String, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, children: content().children)
    }
}

extension Menu: MenuElement where Body == MenuInMenu {
    public init(title: String, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, children: content().children)
    }
}

extension Menu: TransportBarElement where Body == MenuInTransportBar {
    public init(title: String, image: UIImage, @MenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, children: content().children)
    }
}
