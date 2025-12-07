//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable fatal_error_message file_types_order unavailable_function

import SwiftUI

/// A button.
///
/// Buttons can be displayed contextually, in info view actions or in a transport bar (either at top level or in
/// associated menus).
public struct Button<Body, Value> {
    /// The associated body.
    public let body: Body
}

// MARK: Contextual actions embedding

/// The body of a button displayed in contextual actions.
public struct ButtonInContextualActions: ContextualActionsBody {
    let title: String
    let image: UIImage?
    let action: () -> Void

    // swiftlint:disable:next missing_docs
    public func toAction() -> UIAction {
        UIAction.uniqueAction(title: title, image: image) { _ in action() }
    }
}

extension Button: ContextualActionsElement where Body == ButtonInContextualActions, Value == Never {
    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage? = nil, action: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, image: UIImage? = nil, action: @escaping () -> Void) {
        self.init(String(localized: title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, systemImage: String, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, action: action)
    }
}

// MARK: Info view actions embedding

/// The body of a button displayed in info view actions.
public struct ButtonInInfoViewActions: InfoViewActionsBody {
    let title: String
    let image: UIImage?
    let action: () -> Void

    // swiftlint:disable:next missing_docs
    public func toAction(dismissing viewController: UIViewController) -> UIAction {
        UIAction.uniqueAction(title: title, image: image) { [weak viewController] _ in
            action()
            viewController?.dismiss(animated: true)
        }
    }
}

extension Button: InfoViewActionsElement where Body == ButtonInInfoViewActions, Value == Never {
    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage? = nil, action: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, image: UIImage? = nil, action: @escaping () -> Void) {
        self.init(String(localized: title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, systemImage: String, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, action: action)
    }
}

// MARK: Menu embedding

/// The body of a button displayed in a menu.
public struct ButtonInMenu: MenuBody {
    let title: String
    let image: UIImage?
    let action: () -> Void

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIAction.uniqueAction(title: title, image: image) { _ in action() }
    }
}

extension Button: MenuElement where Body == ButtonInMenu, Value == Never {
    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage? = nil, action: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, image: UIImage? = nil, action: @escaping () -> Void) {
        self.init(String(localized: title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, systemImage: String, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, action: action)
    }
}

// MARK: Picker embedding

@available(*, unavailable, message: "Buttons are not supported in pickers")
extension Button: PickerElement where Body == PickerBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: UIImage? = nil, action: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: ImageResource, action: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, systemImage: String, action: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Picker section embedding

@available(*, unavailable, message: "Buttons are not supported in picker sections")
extension Button: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: UIImage? = nil, action: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: ImageResource, action: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, systemImage: String, action: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Section embedding

/// The body of a button displayed in a section.
public struct ButtonInSection: SectionBody {
    let title: String
    let image: UIImage?
    let action: () -> Void

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIAction.uniqueAction(title: title, image: image) { _ in action() }
    }
}

extension Button: SectionElement where Body == ButtonInSection, Value == Never {
    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage? = nil, action: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, image: UIImage? = nil, action: @escaping () -> Void) {
        self.init(String(localized: title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, systemImage: String, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, action: action)
    }
}

// MARK: Transport bar embedding

/// The body of a button displayed in a transport bar.
public struct ButtonInTransportBar: TransportBarBody {
    let title: String
    let image: UIImage
    let action: () -> Void

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIAction.uniqueAction(title: title, image: image) { _ in action() }
    }
}

extension Button: TransportBarElement where Body == ButtonInTransportBar, Value == Never {
    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage, action: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, image: UIImage, action: @escaping () -> Void) {
        self.init(String(localized: title), image: image, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - image: The image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, action: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, action: action)
    }

    /// Creates a button.
    ///
    /// - Parameters:
    ///   - title: The button's title.
    ///   - systemImage: The name of the system symbol image associated with the button.
    ///   - action: A closure triggered when the user presses the button.
    public init(_ title: LocalizedStringResource, systemImage: String, action: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, action: action)
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init<S>(_ title: S, action: @escaping () -> Void) where S: StringProtocol {
        // swiftlint:disable:previous missing_docs
        fatalError()
    }
}

// swiftlint:enable fatal_error_message file_types_order unavailable_function
