//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// An action displayed by a context menu.
public struct ActionInContext: ContextualAction {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toUIAction() -> UIAction {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

/// An action displayed in the info view panel.
public struct ActionInInfoView: InfoViewAction {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toUIAction(dismissing viewController: UIViewController) -> UIAction {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { [weak viewController] _ in
            viewController?.dismiss(animated: true)
            handler()
        }
    }
}

/// An action displayed in an inline menu.
public struct ActionInInlineMenu: InlineMenuElement {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

/// An action displayed in a menu.
public struct ActionInMenu: MenuElement {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

/// An action displayed in a selection menu
public struct ActionInSelectionMenu: SelectionMenuElement {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { action in
            handler()
            action.state = .on
        }
    }
}

/// An action displayed in the transport bar.
public struct ActionInTransportBar: TransportBarElement {
    let title: String
    let image: UIImage
    let handler: () -> Void

    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

/// An action.
public struct Action<Body> {
    private let body: Body
}

extension Action: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    // swiftlint:disable:next missing_docs
    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension Action: UIContextualActionConvertible where Body: UIContextualActionConvertible {
    // swiftlint:disable:next missing_docs
    public func toUIAction() -> UIAction {
        body.toUIAction()
    }
}

extension Action: UIInfoViewActionConvertible where Body: UIInfoViewActionConvertible {
    // swiftlint:disable:next missing_docs
    public func toUIAction(dismissing viewController: UIViewController) -> UIAction {
        body.toUIAction(dismissing: viewController)
    }
}

extension Action: ContextualAction where Body == ActionInContext {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: InfoViewAction where Body == ActionInInfoView {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: InlineMenuElement where Body == ActionInInlineMenu {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: MenuElement where Body == ActionInMenu {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: SelectionMenuElement where Body == ActionInSelectionMenu {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void = {}) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void = {}) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void = {}) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void = {}) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: TransportBarElement where Body == ActionInTransportBar {
    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - image: The image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, image: UIImage, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage)!, handler: handler)
    }

    /// Creates an action.
    ///
    /// - Parameters:
    ///   - title: The action's title.
    ///   - systemImage: The name of the system symbol image that can appear next to this action, if needed.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage)!, handler: handler)
    }
}
