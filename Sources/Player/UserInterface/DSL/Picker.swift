import SwiftUI

public struct Picker<Body, Value> {
    public let body: Body
}

// MARK: `ContextualActions` embedding

@available(*, unavailable, message: "Pickers are not supported as contextual actions")
extension Picker: ContextualActionsElement where Body == ContextualActionsBodyNotSupported {
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `InfoViewActions` embedding

@available(*, unavailable, message: "Pickers are not supported as info view actions")
extension Picker: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported {
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `Menu` embedding

public struct PickerInMenu<Value>: MenuBody {
    let title: String
    let image: UIImage?
    let selection: Binding<Value>
    let content: PickerContent<Value>

    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, options: .singleSelection, children: content.toMenuElements(updating: selection))
    }
}

extension Picker: MenuElement where Body == PickerInMenu<Value> {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, selection: selection, content: content())
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), selection: selection, content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }

    public init(title: LocalizedStringResource, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }
}

// MARK: `Picker` embedding

@available(*, unavailable, message: "Nested pickers are not supported")
extension Picker: PickerElement where Body == PickerBodyNotSupported<Value> {
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `PickerSection` embedding

@available(*, unavailable, message: "Pickers cannot be nested in picker sections")
extension Picker: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `Section` embedding

public struct PickerInSection<Value>: SectionBody {
    let title: String
    let image: UIImage?
    let selection: Binding<Value>
    let content: PickerContent<Value>

    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, options: .singleSelection, children: content.toMenuElements(updating: selection))
    }
}

extension Picker: SectionElement where Body == PickerInSection<Value> {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, selection: selection, content: content())
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), selection: selection, content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }

    public init(title: LocalizedStringResource, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }
}

// MARK: `TransportBar` embedding

public struct PickerInTransportBar<Value>: TransportBarBody {
    let title: String
    let image: UIImage
    let selection: Binding<Value>
    let content: PickerContent<Value>

    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, options: .singleSelection, children: content.toMenuElements(updating: selection))
    }
}

extension Picker: TransportBarElement where Body == PickerInTransportBar<Value> {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, selection: selection, content: content())
    }

    public init(title: LocalizedStringResource, image: UIImage, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), selection: selection, content: content)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }

    public init(title: LocalizedStringResource, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init<S>(title: S, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }
}
