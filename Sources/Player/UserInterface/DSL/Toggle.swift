//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// swiftlint:disable fatal_error_message file_types_order unavailable_function

public struct Toggle<Body, Value> {
    public let body: Body
}

// MARK: `ContextualActions` embedding

@available(*, unavailable, message: "Toggles are not supported as contextual actions")
extension Toggle: ContextualActionsElement where Body == ContextualActionsBodyNotSupported, Value == Never {
    public init<S>(title: S, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `InfoViewActions` embedding

@available(*, unavailable, message: "Toggles are not supported as info view actions")
extension Toggle: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported, Value == Never {
    public init<S>(title: S, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `Menu` embedding

public struct ToggleInMenu: MenuBody {
    let title: String
    let image: UIImage?
    let isOn: Binding<Bool>
    let handler: (Bool) -> Void

    private func state(isOn: Binding<Bool>) -> UIMenuElement.State {
        isOn.wrappedValue ? .on : .off
    }

    public func toMenuElement() -> UIMenuElement {
        UIAction(title: title, image: image, state: state(isOn: isOn)) { action in
            isOn.wrappedValue.toggle()
            action.state = state(isOn: isOn)
            handler(isOn.wrappedValue)
        }
    }
}

extension Toggle: MenuElement where Body == ToggleInMenu, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, isOn: isOn, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: image, isOn: isOn, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }
}

// MARK: `Picker` embedding

@available(*, unavailable, message: "Toggles are not supported in pickers")
extension Toggle: PickerElement where Body == PickerBodyNotSupported<Value> {
    public init<S>(title: S, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `PickerSection` embedding

@available(*, unavailable, message: "Toggles are not supported in picker sections")
extension Toggle: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    public init<S>(title: S, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }

    public init<S>(title: S, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        fatalError()
    }
}

// MARK: `Section` embedding

public struct ToggleInSection: SectionBody {
    let title: String
    let image: UIImage?
    let isOn: Binding<Bool>
    let handler: (Bool) -> Void

    public func toMenuElement() -> UIMenuElement {
        let action = UIAction(title: title, image: image) { action in
            isOn.wrappedValue.toggle()
            action.state = isOn.wrappedValue ? .on : .off
            handler(isOn.wrappedValue)
        }
        action.state = isOn.wrappedValue ? .on : .off
        return action
    }
}

extension Toggle: SectionElement where Body == ToggleInSection, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, isOn: isOn, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage? = nil, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: image, isOn: isOn, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }
}

// MARK: `TransportBar` embedding

public struct ToggleInTransportBar: TransportBarBody {
    let title: String
    let image: UIImage
    let isOn: Binding<Bool>
    let handler: (Bool) -> Void

    public func toMenuElement() -> UIMenuElement {
        let action = UIAction(title: title, image: image) { action in
            isOn.wrappedValue.toggle()
            action.state = isOn.wrappedValue ? .on : .off
            handler(isOn.wrappedValue)
        }
        action.state = isOn.wrappedValue ? .on : .off
        return action
    }
}

extension Toggle: TransportBarElement where Body == ToggleInTransportBar, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, isOn: isOn, handler: handler)
    }

    public init(title: LocalizedStringResource, image: UIImage, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: image, isOn: isOn, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(resource: image), isOn: isOn, handler: handler)
    }

    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }

    public init(title: LocalizedStringResource, systemImage: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, isOn: isOn, handler: handler)
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init(title: String, isOn: Binding<Bool>, handler: @escaping (Bool) -> Void = { _ in }) {
        fatalError()
    }
}

// swiftlint:enable fatal_error_message file_types_order unavailable_function
