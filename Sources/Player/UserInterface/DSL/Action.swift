import SwiftUI

public struct Action<Body, Value> {
    public let body: Body
}

// MARK: `ContextualActions` embedding

public struct ActionInContextualActions: ContextualActionsBody {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toAction() -> UIAction {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { _ in handler() }
    }
}

extension Action: ContextualActionsElement where Body == ActionInContextualActions, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }
}

// MARK: `InfoViewActions` embedding

public struct ActionInInfoViewActions: InfoViewActionsBody {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toAction(dismissing viewController: UIViewController) -> UIAction {
        UIAction(title: title, image: image, identifier: .init(rawValue: title)) { [weak viewController] _ in
            handler()
            viewController?.dismiss(animated: true)
        }
    }
}

extension Action: InfoViewActionsElement where Body == ActionInInfoViewActions, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }
}

// MARK: `Menu` embedding

public struct ActionInMenu: MenuBody {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image) { _ in handler() }
    }
}

extension Action: MenuElement where Body == ActionInMenu, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }
}

// MARK: `Picker` embedding

@available(*, unavailable, message: "Actions are not supported in pickers")
extension Action: PickerElement where Body == PickerBodyNotSupported<Value> {
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `PickerSection` embedding

@available(*, unavailable, message: "Actions are not supported in picker sections")
extension Action: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `Section` embedding

public struct ActionInSection: SectionBody {
    let title: String
    let image: UIImage?
    let handler: () -> Void

    public func toMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image) { _ in handler() }
    }
}

extension Action: SectionElement where Body == ActionInSection, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }
}

// MARK: `TransportBar` embedding

public struct ActionInTransportBar: TransportBarBody {
    let title: String
    let image: UIImage
    let handler: () -> Void

    public func toMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image) { _ in handler() }
    }
}

extension Action: TransportBarElement where Body == ActionInTransportBar, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, handler: @escaping () -> Void) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: image, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(resource: image), handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, handler: @escaping () -> Void) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, handler: @escaping () -> Void) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, handler: handler)
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init<S>(title: S, handler: @escaping () -> Void) where S: StringProtocol {
        fatalError()
    }
}
