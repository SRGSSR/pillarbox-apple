import SwiftUI

public struct Menu<Body, Value> {
    public let body: Body
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
    public init(title: String, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, content: content())
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
    public init(title: String, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, content: content())
    }
}

// MARK: `Picker` embedding

extension Menu: PickerElement where Body == PickerBodyNotSupported<Value> {
    @available(*, unavailable, message: "Menus are not supported in picker sections. Use a `Picker` without `selection` parameter instead")
    public init(title: String, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        fatalError()
    }
}

// MARK: `PickerSection` embedding

extension Menu: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    @available(*, unavailable, message: "Menus are not supported in picker sections")
    public init(title: String, image: UIImage? = nil, @MenuContentBuilder content: () -> MenuContent) {
        fatalError()
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
    public init(title: String, image: UIImage, @MenuContentBuilder content: () -> MenuContent) {
        self.body = .init(title: title, image: image, content: content())
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init(title: String, @MenuContentBuilder content: () -> MenuContent) {
        fatalError()
    }
}
