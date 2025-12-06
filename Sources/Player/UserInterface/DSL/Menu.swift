import SwiftUI

public struct Menu<Body, Value> {
    public let body: Body
}

// MARK: `ContextualActions` embedding

@available(*, unavailable, message: "Menus are not supported as contextual actions")
extension Menu: ContextualActionsElement where Body == ContextualActionsBodyNotSupported, Value == Never {
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
    
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `InfoViewActions` embedding

@available(*, unavailable, message: "Menus are not supported as info view actions")
extension Menu: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported, Value == Never {
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `Menu` embedding

public struct MenuInMenu: MenuBody {
    let title: String
    let image: UIImage?
    let content: MenuContent

    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, children: content.toMenuElements())
    }
}

extension Menu: MenuElement where Body == MenuInMenu, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, content: content())
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(resource: image), content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, content: content)
    }

    public init(title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

// MARK: `Picker` embedding

@available(*, unavailable, message: "Menus are not supported in pickers")
extension Menu: PickerElement where Body == PickerBodyNotSupported<Value> {
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `PickerSection` embedding

@available(*, unavailable, message: "Menus are not supported in picker sections")
extension Menu: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `Section` embedding

public struct MenuInSection: SectionBody {
    let title: String
    let image: UIImage?
    let content: MenuContent

    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, children: content.toMenuElements())
    }
}

extension Menu: SectionElement where Body == MenuInSection, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, content: content())
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(resource: image), content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, content: content)
    }

    public init(title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }
}

// MARK: `TransportBar` embedding

public struct MenuInTransportBar: TransportBarBody {
    let title: String
    let image: UIImage
    let content: MenuContent

    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, children: content.toMenuElements())
    }
}

extension Menu: TransportBarElement where Body == MenuInTransportBar, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, content: content())
    }

    public init(title: LocalizedStringResource, image: UIImage, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: image, content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(resource: image), content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, @MenuContentBuilder content: () -> MenuContent) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, content: content)
    }

    public init(title: LocalizedStringResource, systemImage: String, @MenuContentBuilder content: () -> MenuContent) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, content: content)
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init(title: String, @MenuContentBuilder content: () -> MenuContent) {
        fatalError()
    }
}
