//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// swiftlint:disable fatal_error_message file_types_order line_length unavailable_function

/// A menu.
///
/// Menus can be used to arrange transport bar items hierarchically.
public struct Menu<Body, Value> {
    /// The associated body.
    public let body: Body
}

// MARK: Contextual actions embedding

@available(*, unavailable, message: "Menus are not supported as contextual actions")
extension Menu: ContextualActionsElement where Body == ContextualActionsBodyNotSupported, Value == Never {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Info view actions embedding

@available(*, unavailable, message: "Menus are not supported as info view actions")
extension Menu: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported, Value == Never {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Inline picker embedding

@available(*, unavailable, message: "Menus are not supported in inline pickers")
extension Menu: InlinePickerElement where Body == InlinePickerBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Menu embedding

/// The body of a menu displayed in another menu.
public struct MenuInMenu: MenuBody {
    let title: String
    let subtitle: String?
    let image: UIImage?
    let content: MenuContent

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement? {
        UIMenu.identifiedMenu(title: title, subtitle: subtitle, image: image, children: content.toMenuElements())
    }
}

@available(iOS 17.0, tvOS 18.0, *)
extension Menu: MenuElement where Body == MenuInMenu, Value == Never {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), subtitle: String(optional: subtitle), image: image, content: content())
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(String(title), subtitle: String(optional: subtitle), image: UIImage(resource: image), content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: UIImage(resource: image), content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - systemImage: The name of the system symbol image associated with the menu.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(String(title), subtitle: String(optional: subtitle), image: UIImage(systemName: systemImage)!, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - systemImage: The name of the system symbol image associated with the menu.
    ///   - content: The menu's content.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: UIImage(systemName: systemImage)!, content: content)
    }
}

// MARK: Picker embedding

@available(*, unavailable, message: "Menus are not supported in pickers")
extension Menu: PickerElement where Body == PickerBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Picker section embedding

@available(*, unavailable, message: "Menus are not supported in picker sections")
extension Menu: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Section embedding

/// The body of a menu displayed in a section.
public struct MenuInSection: SectionBody {
    let title: String
    let subtitle: String?
    let image: UIImage?
    let content: MenuContent

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement? {
        UIMenu.identifiedMenu(title: title, subtitle: subtitle, image: image, children: content.toMenuElements())
    }
}

@available(iOS 17.0, tvOS 18.0, *)
extension Menu: SectionElement where Body == MenuInSection, Value == Never {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), subtitle: String(optional: subtitle), image: image, content: content())
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(String(title), subtitle: String(optional: subtitle), image: UIImage(resource: image), content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: UIImage(resource: image), content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - systemImage: The name of the system symbol image associated with the menu.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(String(title), subtitle: String(optional: subtitle), image: UIImage(systemName: systemImage)!, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - subtitle: The menu's subtitle.
    ///   - systemImage: The name of the system symbol image associated with the menu.
    ///   - content: The menu's content.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: UIImage(systemName: systemImage)!, content: content)
    }
}

// MARK: Transport bar embedding

/// The body of a menu displayed in a transport bar.
public struct MenuInTransportBar: TransportBarBody {
    let title: String
    let image: UIImage
    let content: MenuContent

    private func children() -> [UIMenuElement] {
        // TODO: Nested menus are not officially supported by the tvOS transport bar. In practice they work well,
        //       except when a transport-bar-level menu contains only nested (non-inline) menus. In those cases,
        //       we insert a dummy disabled action to ensure the menu is displayed. This code can be removed if
        //       this behavior is improved in the future.
        var elements = content.toMenuElements()
        if !elements.isEmpty && elements.allSatisfy(\.isNestedMenu) {
            let emptyAction = UIAction(attributes: .disabled) { _ in }
            elements.append(emptyAction)
        }
        return elements
    }

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement? {
        UIMenu.identifiedMenu(title: title, image: image, children: children())
    }
}

extension Menu: TransportBarElement where Body == MenuInTransportBar, Value == Never {
    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, content: content())
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    public init(_ title: LocalizedStringResource, image: UIImage, @MenuContentBuilder content: () -> MenuContent) {
        self.init(String(localized: title), image: image, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - image: The image associated with the menu.
    ///   - content: The menu's content.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) {
        self.init(String(localized: title), image: UIImage(resource: image), content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image associated with the menu.
    ///   - content: The menu's content.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, content: content)
    }

    /// Creates a menu.
    ///
    /// - Parameters:
    ///   - title: The menu's title.
    ///   - systemImage: The name of the system symbol image associated with the menu.
    ///   - content: The menu's content.
    public init(_ title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init(_ title: String, @MenuContentBuilder content: () -> MenuContent) {
        // swiftlint:disable:previous missing_docs
        fatalError()
    }
}

// swiftlint:enable fatal_error_message file_types_order line_length unavailable_function
