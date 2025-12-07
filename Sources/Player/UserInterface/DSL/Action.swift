//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

// swiftlint:disable fatal_error_message file_types_order unavailable_function

import SwiftUI

/// An action.
///
/// Actions can be displayed contextually, in info view actions or in a transport bar (either at top level or in
/// associated menus).
public struct Action<Body, Value> {
    /// The associated body.
    public let body: Body
}

// MARK: Contextual actions embedding

/// The body of an action displayed in contextual actions.
public struct ActionInContextualActions: ContextualActionsBody {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toAction() -> UIAction {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

extension Action: ContextualActionsElement where Body == ActionInContextualActions, Value == Never {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }
}

// MARK: Info view actions embedding

/// The body of an action displayed in info view actions.
public struct ActionInInfoViewActions: InfoViewActionsBody {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toAction(dismissing viewController: UIViewController) -> UIAction {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { [weak viewController] _ in
            handler()
            viewController?.dismiss(animated: true)
        }
    }
}

extension Action: InfoViewActionsElement where Body == ActionInInfoViewActions, Value == Never {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }
}

// MARK: Menu embedding

/// The body of an action displayed in a menu.
public struct ActionInMenu: MenuBody {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image) { _ in handler() }
    }
}

extension Action: MenuElement where Body == ActionInMenu, Value == Never {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }
}

// MARK: Picker embedding

@available(*, unavailable, message: "Actions are not supported in pickers")
extension Action: PickerElement where Body == PickerBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Picker section embedding

@available(*, unavailable, message: "Actions are not supported in picker sections")
extension Action: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Section embedding

/// The body of an action displayed in a section.
public struct ActionInSection: SectionBody {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image) { _ in handler() }
    }
}

extension Action: SectionElement where Body == ActionInSection, Value == Never {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }
}

// MARK: Transport bar embedding

/// The body of an action displayed in a transport bar.
public struct ActionInTransportBar: TransportBarBody {
    let title: String
    let image: UIImage
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image) { _ in handler() }
    }
}

extension Action: TransportBarElement where Body == ActionInTransportBar, Value == Never {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, image: UIImage, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image associated with the action.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(_ title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init<S>(_ title: S, handler: @escaping () -> Void) where S: StringProtocol {
        // swiftlint:disable:previous missing_docs
        fatalError()
    }
}

// swiftlint:enable fatal_error_message file_types_order unavailable_function
