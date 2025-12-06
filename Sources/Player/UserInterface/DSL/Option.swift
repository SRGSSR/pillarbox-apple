import SwiftUI

public struct Option<Body, Value> {
    public let body: Body
}

// MARK: `ContextualActions` embedding

@available(*, unavailable, message: "Options are not supported as contextual actions")
extension Option: ContextualActionsElement where Body == ContextualActionsBodyNotSupported {
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `InfoViewActions` embedding

@available(*, unavailable, message: "Options are not supported as info view actions")
extension Option: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported {
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `Menu` embedding

@available(*, unavailable, message: "Options cannot be used in menus. Use a `Picker` instead")
extension Option: MenuElement where Body == MenuBodyNotSupported {
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `Picker` embedding

public struct OptionInPicker<Value>: PickerBody where Value: Equatable {
    let title: String
    let image: UIImage?
    let value: Value
    let handler: (Value) -> Void

    private func state(selection: Binding<Value>) -> UIMenuElement.State {
        selection.wrappedValue == value ? .on : .off
    }

    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        UIAction(title: title, image: image, state: state(selection: selection)) { action in
            selection.wrappedValue = value
            action.state = state(selection: selection)
            handler(value)
        }
    }
}

extension Option: PickerElement where Body == OptionInPicker<Value> {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, value: value, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: image, value: value, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), value: value, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(resource: image), value: value, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, value: value, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, value: value, handler: handler)
    }
}

// MARK: `PickerSection` embedding

public struct OptionInPickerSection<Value>: PickerSectionBody where Value: Equatable {
    let title: String
    let image: UIImage?
    let value: Value
    let handler: (Value) -> Void

    private func state(selection: Binding<Value>) -> UIMenuElement.State {
        selection.wrappedValue == value ? .on : .off
    }

    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        UIAction(title: title, image: image, state: state(selection: selection)) { action in
            selection.wrappedValue = value
            action.state = state(selection: selection)
            handler(value)
        }
    }
}

extension Option: PickerSectionElement where Body == OptionInPickerSection<Value> {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, value: value, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: image, value: value, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), value: value, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(resource: image), value: value, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, value: value, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, value: value, handler: handler)
    }
}

// MARK: `Section` embedding

@available(*, unavailable, message: "Options cannot be used in sections not belonging to a `Picker`")
extension Option: SectionElement where Body == SectionBodyNotSupported {
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `TransportBar` embedding

@available(*, unavailable, message: "Options cannot be displayed at the transport bar root level")
extension Option: TransportBarElement where Body == TransportBarBodyNotSupported {
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}
