//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// swiftlint:disable fatal_error_message file_types_order line_length unavailable_function

/// A toggle.
///
/// Toggles can be used to add settings that can be simply enabled or disabled to a transport bar, either at top level
/// or in associated menus.
public struct Toggle<Body, Value> {
    /// The associated body.
    public let body: Body
}

// MARK: Contextual actions embedding

@available(*, unavailable, message: "Toggles are not supported as contextual actions")
extension Toggle: ContextualActionsElement where Body == ContextualActionsBodyNotSupported, Value == Never {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Info view actions embedding

@available(*, unavailable, message: "Toggles are not supported as info view actions")
extension Toggle: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported, Value == Never {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Inline picker embedding

@available(*, unavailable, message: "Toggles are not supported in inline pickers")
extension Toggle: InlinePickerElement where Body == InlinePickerBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, subtitle: S? = nil, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Menu embedding

/// The body of a toggle displayed in a menu.
public struct ToggleInMenu: MenuBody {
    let title: String
    let subtitle: String?
    let image: UIImage?
    let isOn: Binding<Bool>
    let handler: (Bool) -> Void

    private func state(isOn: Binding<Bool>) -> UIMenuElement.State {
        isOn.wrappedValue ? .on : .off
    }

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement? {
        UIAction(title: title, subtitle: subtitle, image: image, state: state(isOn: isOn)) { action in
            isOn.wrappedValue.toggle()
            action.state = state(isOn: isOn)
            handler(isOn.wrappedValue)
        }
    }
}

extension Toggle: MenuElement where Body == ToggleInMenu, Value == Never {
    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), subtitle: String(optional: subtitle), image: image, isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: image, isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(String(title), subtitle: String(optional: subtitle), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - systemImage: The name of the system symbol image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(String(title), subtitle: String(optional: subtitle), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - systemImage: The name of the system symbol image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }
}

// MARK: Picker embedding

@available(*, unavailable, message: "Toggles are not supported in pickers")
extension Toggle: PickerElement where Body == PickerBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, subtitle: S? = nil, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, subtitle: S? = nil, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Picker section embedding

@available(*, unavailable, message: "Toggles are not supported in picker sections")
extension Toggle: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, subtitle: S? = nil, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, subtitle: S? = nil, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, subtitle: S? = nil, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Section embedding

/// The body of a toggle displayed in a section.
public struct ToggleInSection: SectionBody {
    let title: String
    let subtitle: String?
    let image: UIImage?
    let isOn: Binding<Bool>
    let handler: (Bool) -> Void

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement? {
        let action = UIAction(title: title, subtitle: subtitle, image: image) { action in
            isOn.wrappedValue.toggle()
            action.state = isOn.wrappedValue ? .on : .off
            handler(isOn.wrappedValue)
        }
        action.state = isOn.wrappedValue ? .on : .off
        return action
    }
}

extension Toggle: SectionElement where Body == ToggleInSection, Value == Never {
    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), subtitle: String(optional: subtitle), image: image, isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: image, isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(String(title), subtitle: String(optional: subtitle), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - systemImage: The name of the system symbol image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @_disfavoredOverload
    public init<S>(_ title: S, subtitle: S? = nil, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(String(title), subtitle: String(optional: subtitle), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - subtitle: The toggle's subtitle.
    ///   - systemImage: The name of the system symbol image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    public init(_ title: LocalizedStringResource, subtitle: LocalizedStringResource? = nil, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(String(localized: title), subtitle: String(localizedOptional: subtitle), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }
}

// MARK: Transport bar embedding

/// The body of a toggle displayed in a transport bar.
public struct ToggleInTransportBar: TransportBarBody {
    let title: String
    let image: UIImage
    let isOn: Binding<Bool>
    let handler: (Bool) -> Void

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement? {
        let action = UIAction.identifiedAction(title: title, image: image) { action in
            isOn.wrappedValue.toggle()
            action.state = isOn.wrappedValue ? .on : .off
            handler(isOn.wrappedValue)
        }
        action.state = isOn.wrappedValue ? .on : .off
        return action
    }
}

extension Toggle: TransportBarElement where Body == ToggleInTransportBar, Value == Never {
    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @_disfavoredOverload
    public init<S>(_ title: S, image: UIImage, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    public init(_ title: LocalizedStringResource, image: UIImage, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(String(localized: title), image: image, isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(_ title: S, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(String(title), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - image: The image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(_ title: LocalizedStringResource, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(String(localized: title), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - systemImage: The name of the system symbol image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    @_disfavoredOverload
    public init<S>(_ title: S, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(String(title), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }

    /// Creates a toggle.
    ///
    /// - Parameters:
    ///   - title: The toggle's title.
    ///   - systemImage: The name of the system symbol image associated with the toggle.
    ///   - isOn: A binding to a property that determines whether the toggle is on or off.
    ///   - handler: The handler to invoke when the user interacts with the toggle.
    public init(_ title: LocalizedStringResource, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(String(localized: title), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init<S>(_ title: S, subtitle: S? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        // swiftlint:disable:previous missing_docs
        fatalError()
    }
}

// swiftlint:enable fatal_error_message file_types_order line_length unavailable_function
