//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A selection menu displayed in an inline menu.
public struct SelectionMenuInInlineMenu: InlineMenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), options: [.singleSelection], children: children)
    }
}

/// A selection menu displayed in a menu.
public struct SelectionMenuInMenu: MenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), options: [.singleSelection], children: children)
    }
}

/// A selection menu displayed in a selection menu.
public struct SelectionMenuInSelectionMenu: SelectionMenuElement {
    let title: String
    let image: UIImage?
    let children: [UIMenuElement]

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), options: [.singleSelection], children: children)
    }
}

/// A selection menu displayed in the transport bar.
public struct SelectionMenuInTransportBar: TransportBarElement {
    let title: String
    let image: UIImage
    let children: [UIMenuElement]

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, identifier: .init(rawValue: title), options: [.singleSelection], children: children)
    }
}

/// A selection menu.
public struct SelectionMenu<Body> {
    private let body: Body
}

extension SelectionMenu: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension SelectionMenu: InlineMenuElement where Body == SelectionMenuInInlineMenu {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: UIImage(systemName: systemImage)!, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension SelectionMenu: MenuElement where Body == SelectionMenuInMenu {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: UIImage(systemName: systemImage)!, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension SelectionMenu: SelectionMenuElement where Body == SelectionMenuInSelectionMenu {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, image: UIImage? = nil, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: UIImage(systemName: systemImage)!, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

extension SelectionMenu: TransportBarElement where Body == SelectionMenuInTransportBar {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, image: UIImage, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: UIImage(systemName: systemImage)!, children: content().children)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this menu, if needed.
    ///   - content: The menu's content.
    public init(title: LocalizedStringResource, systemImage: String, @SelectionMenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}
