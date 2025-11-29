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

public struct SelectionMenu<Body> {
    private let body: Body
}

extension SelectionMenu: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension SelectionMenu: InlineMenuElement where Body == SelectionMenuInInlineMenu {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: UIImage(systemName: systemImage)!, children: content().children)
    }

    public init(title: LocalizedStringResource, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension SelectionMenu: MenuElement where Body == SelectionMenuInMenu {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: UIImage(systemName: systemImage)!, children: content().children)
    }

    public init(title: LocalizedStringResource, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension SelectionMenu: SelectionMenuElement where Body == SelectionMenuInSelectionMenu {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: UIImage(systemName: systemImage)!, children: content().children)
    }

    public init(title: LocalizedStringResource, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension SelectionMenu: TransportBarElement where Body == SelectionMenuInTransportBar {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    public init(title: LocalizedStringResource, image: UIImage, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: UIImage(systemName: systemImage)!, children: content().children)
    }

    public init(title: LocalizedStringResource, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}
