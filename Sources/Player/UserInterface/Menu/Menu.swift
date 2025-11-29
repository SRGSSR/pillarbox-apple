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
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage)!, content: content)
    }

    public init(title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension Menu: MenuElement where Body == MenuInMenu {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage)!, content: content)
    }

    public init(title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension Menu: TransportBarElement where Body == MenuInTransportBar {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    public init(title: LocalizedStringResource, image: UIImage, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage)!, content: content)
    }

    public init(title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}
