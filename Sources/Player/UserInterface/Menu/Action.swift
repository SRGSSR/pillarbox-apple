//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct ActionInContext: ContextualAction {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toUIAction() -> UIAction {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

public struct ActionInInfoView: InfoViewAction {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toUIAction(dismissing viewController: UIViewController) -> UIAction {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { [weak viewController] _ in
            viewController?.dismiss(animated: true)
            handler()
        }
    }
}

public struct ActionInInlineMenu: InlineMenuElement {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

public struct ActionInMenu: MenuElement {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

public struct ActionInSelectionMenu: SelectionMenuElement {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { action in
            handler()
            action.state = .on
        }
    }
}

public struct ActionInTransportBar: TransportBarElement {
    let title: String
    let image: UIImage
    let handler: () -> Void

    public func toUIMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

public struct Action<Body> {
    private let body: Body
}

extension Action: UIMenuElementConvertible where Body: UIMenuElementConvertible {
    public func toUIMenuElement() -> UIMenuElement {
        body.toUIMenuElement()
    }
}

extension Action: UIContextualActionConvertible where Body: UIContextualActionConvertible {
    public func toUIAction() -> UIAction {
        body.toUIAction()
    }
}

extension Action: UIInfoViewActionConvertible where Body: UIInfoViewActionConvertible {
    public func toUIAction(dismissing viewController: UIViewController) -> UIAction {
        body.toUIAction(dismissing: viewController)
    }
}

extension Action: ContextualAction where Body == ActionInContext {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: InfoViewAction where Body == ActionInInfoView {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: InlineMenuElement where Body == ActionInInlineMenu {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: MenuElement where Body == ActionInMenu {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: SelectionMenuElement where Body == ActionInSelectionMenu {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void = {}) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void = {}) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void = {}) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void = {}) {
        self.init(title: title, image: UIImage(systemName: systemImage), handler: handler)
    }
}

extension Action: TransportBarElement where Body == ActionInTransportBar {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: title, image: UIImage(systemName: systemImage)!, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: title, image: UIImage(systemName: systemImage)!, handler: handler)
    }
}
