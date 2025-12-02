//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A menu displayed in an inline menu.
public struct MenuInInlineMenu: InlineMenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), children: children)
    }
}

/// A menu displayed in a menu.
public struct MenuInMenu: MenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), children: children)
    }
}

/// A menu displayed in the transport bar
public struct MenuInTransportBar: TransportBarElement {
    let title: String
    let image: UIImage
    let children: [UIMenuElement]

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), children: children)
    }
}

/// A menu.
public struct Menu<Body> {
    private let body: Body
}

extension Menu: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension Menu: InlineMenuElement where Body == MenuInInlineMenu {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage)!, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension Menu: MenuElement where Body == MenuInMenu {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage)!, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension Menu: TransportBarElement where Body == MenuInTransportBar {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, image: UIImage, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage)!, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}
