//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// swiftlint:disable fatal_error_message file_types_order unavailable_function

/// An option.
///
/// Options provide choices offered by a ``Picker``.
public struct Option<Body, Value> {
    /// The associated body.
    public let body: Body
}

// MARK: Contextual actions embedding

@available(*, unavailable, message: "Options are not supported as contextual actions")
extension Option: ContextualActionsElement where Body == ContextualActionsBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Info view actions embedding

@available(*, unavailable, message: "Options are not supported as info view actions")
extension Option: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Menu embedding

@available(*, unavailable, message: "Options cannot be used in menus. Use a `Picker` instead")
extension Option: MenuElement where Body == MenuBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Picker embedding

/// The body of an option displayed in a picker.
public struct OptionInPicker<Value>: PickerBody where Value: Equatable {
    let title: String
    let image: UIImage?
    let value: Value
    let handler: (Value) -> Void

    private func state(selection: Binding<Value>) -> UIMenuElement.State {
        selection.wrappedValue == value ? .on : .off
    }

    // swiftlint:disable:next missing_docs
    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        UIAction(title: title, image: image, state: state(selection: selection)) { action in
            selection.wrappedValue = value
            action.state = state(selection: selection)
            handler(value)
        }
    }
}

extension Option: PickerElement where Body == OptionInPicker<Value> {
    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - image: The image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - image: The image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: image, value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - image: The image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - image: The image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(resource: image), value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - systemImage: The name of the system symbol image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - systemImage: The name of the system symbol image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, value: value, handler: handler)
    }
}

// MARK: Picker section embedding

/// The body of an option displayed in a picker section.
public struct OptionInPickerSection<Value>: PickerSectionBody where Value: Equatable {
    let title: String
    let image: UIImage?
    let value: Value
    let handler: (Value) -> Void

    private func state(selection: Binding<Value>) -> UIMenuElement.State {
        selection.wrappedValue == value ? .on : .off
    }

    // swiftlint:disable:next missing_docs
    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        UIAction(title: title, image: image, state: state(selection: selection)) { action in
            selection.wrappedValue = value
            action.state = state(selection: selection)
            handler(value)
        }
    }
}

extension Option: PickerSectionElement where Body == OptionInPickerSection<Value> {
    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - image: The image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - image: The image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: image, value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - image: The image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - image: The image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(resource: image), value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - systemImage: The name of the system symbol image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, value: value, handler: handler)
    }

    /// Creates an option.
    ///
    /// - Parameters:
    ///   - title: The option's title.
    ///   - systemImage: The name of the system symbol image associated with the option.
    ///   - value: The value associated with the option.
    ///   - handler: The handler to invoke when the user selects the action.
    public init(title: LocalizedStringResource, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, value: value, handler: handler)
    }
}

// MARK: Section embedding

@available(*, unavailable, message: "Options cannot be used in sections not belonging to a `Picker`")
extension Option: SectionElement where Body == SectionBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Transport bar embedding

@available(*, unavailable, message: "Options cannot be displayed at the transport bar root level")
extension Option: TransportBarElement where Body == TransportBarBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: UIImage? = nil, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: ImageResource, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, systemImage: String, value: Value, handler: @escaping (Value) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// swiftlint:enable fatal_error_message file_types_order unavailable_function
