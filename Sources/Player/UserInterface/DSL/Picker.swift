//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// swiftlint:disable fatal_error_message line_length file_types_order unavailable_function

/// A picker.
///
/// A picker provides a choice between related values and can be displayed in a transport bar. Choices are provided
/// using ``Option``s which can be optionally grouped into ``Section``s.
public struct Picker<Body, Value> {
    /// The associated body.
    public let body: Body
}

// MARK: Contextual actions embedding

@available(*, unavailable, message: "Pickers are not supported as contextual actions")
extension Picker: ContextualActionsElement where Body == ContextualActionsBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Info view actions embedding

@available(*, unavailable, message: "Pickers are not supported as info view actions")
extension Picker: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Menu embedding

/// The body of a picker displayed in a menu.
public struct PickerInMenu<Value>: MenuBody {
    let title: String
    let image: UIImage?
    let selection: Binding<Value>
    let content: PickerContent<Value>

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, options: .singleSelection, children: content.toMenuElements(updating: selection))
    }
}

extension Picker: MenuElement where Body == PickerInMenu<Value> {
    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, selection: selection, content: content())
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    public init(title: LocalizedStringResource, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - systemImage: The name of the system symbol image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - systemImage: The name of the system symbol image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    public init(title: LocalizedStringResource, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }
}

// MARK: Picker embedding

@available(*, unavailable, message: "Nested pickers are not supported")
extension Picker: PickerElement where Body == PickerBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Picker section embedding

@available(*, unavailable, message: "Pickers cannot be nested in picker sections")
extension Picker: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        fatalError()
    }
}

// MARK: Section embedding

/// The body of a picker displayed in a section.
public struct PickerInSection<Value>: SectionBody {
    let title: String
    let image: UIImage?
    let selection: Binding<Value>
    let content: PickerContent<Value>

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, options: .singleSelection, children: content.toMenuElements(updating: selection))
    }
}

extension Picker: SectionElement where Body == PickerInSection<Value> {
    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, selection: selection, content: content())
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    public init(title: LocalizedStringResource, image: UIImage? = nil, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - systemImage: The name of the system symbol image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - systemImage: The name of the system symbol image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    public init(title: LocalizedStringResource, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }
}

// MARK: Transport bar embedding

/// The body of a picker displayed in a transport bar.
public struct PickerInTransportBar<Value>: TransportBarBody {
    let title: String
    let image: UIImage
    let selection: Binding<Value>
    let content: PickerContent<Value>

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, image: image, options: .singleSelection, children: content.toMenuElements(updating: selection))
    }
}

extension Picker: TransportBarElement where Body == PickerInTransportBar<Value> {
    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @_disfavoredOverload
    public init<S>(title: S, image: UIImage, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.body = .init(title: String(title), image: image, selection: selection, content: content())
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    public init(title: LocalizedStringResource, image: UIImage, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @available(iOS 17.0, tvOS 17.0, *)
    @_disfavoredOverload
    public init<S>(title: S, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(resource: image), selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - image: The image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @available(iOS 17.0, tvOS 17.0, *)
    public init(title: LocalizedStringResource, image: ImageResource, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: image, selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - systemImage: The name of the system symbol image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @_disfavoredOverload
    public init<S>(title: S, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        self.init(title: String(title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - systemImage: The name of the system symbol image associated with the picker.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    public init(title: LocalizedStringResource, systemImage: String, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) {
        self.init(title: String(localized: title), image: UIImage(systemName: systemImage)!, selection: selection, content: content)
    }

    @available(*, unavailable, message: "Elements displayed at the transport bar root level require an associated image")
    public init<S>(title: S, selection: Binding<Value>, @PickerContentBuilder<Value> content: () -> PickerContent<Value>) where S: StringProtocol {
        // swiftlint:disable:previous missing_docs
        fatalError()
    }
}

// swiftlint:enable fatal_error_message line_length file_types_order unavailable_function
