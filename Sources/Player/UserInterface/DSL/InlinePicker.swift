//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// swiftlint:disable fatal_error_message line_length file_types_order unavailable_function

/// A picker that displays its options inline in its parent.
///
/// A picker provides a choice between related values and can be displayed in a transport bar. Choices are provided
/// using ``Option``s which can be optionally grouped into ``Section``s.
public struct InlinePicker<Body, Value> {
    /// The associated body.
    public let body: Body
}

// MARK: Contextual actions embedding

@available(*, unavailable, message: "Inline pickers are not supported as contextual actions")
extension InlinePicker: ContextualActionsElement where Body == ContextualActionsBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) {
        fatalError()
    }
}

// MARK: Info view actions embedding

@available(*, unavailable, message: "Inline pickers are not supported as info view actions")
extension InlinePicker: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) {
        fatalError()
    }
}

// MARK: Inline picker embedding

@available(*, unavailable, message: "Nested inline pickers are not supported")
extension InlinePicker: InlinePickerElement where Body == InlinePickerBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) {
        fatalError()
    }
}

// MARK: Menu embedding

/// The body of a picker displayed in a menu.
public struct InlinePickerInMenu<Value>: MenuBody {
    let title: String
    let selection: Binding<Value>
    let content: InlinePickerContent<Value>

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIMenu.identifiableMenu(title: title, options: [.singleSelection, .displayInline], children: content.toMenuElements(updating: selection))
    }
}

extension InlinePicker: MenuElement where Body == InlinePickerInMenu<Value> {
    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    @_disfavoredOverload
    public init<S>(_ title: S, selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) where S: StringProtocol {
        self.body = .init(title: String(title), selection: selection, content: content())
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - title: The picker's title.
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    public init(_ title: LocalizedStringResource, selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) {
        self.init(String(localized: title), selection: selection, content: content)
    }

    /// Creates a picker.
    ///
    /// - Parameters:
    ///   - selection: A binding to a property that determines the currently-selected option.
    ///   - content: The picker's content.
    public init(selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) {
        self.init(String(""), selection: selection, content: content)
    }
}

// MARK: Picker embedding

@available(*, unavailable, message: "Nested inline pickers are not supported")
extension InlinePicker: PickerElement where Body == PickerBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) {
        fatalError()
    }
}

// MARK: Picker section embedding

@available(*, unavailable, message: "Inline pickers cannot be nested in picker sections")
extension InlinePicker: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) {
        fatalError()
    }
}

// MARK: Section embedding

@available(*, unavailable, message: "Inline pickers cannot be nested in sections")
extension InlinePicker: SectionElement where Body == SectionBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) {
        fatalError()
    }
}

// MARK: Transport bar embedding

@available(*, unavailable, message: "Inline pickers cannot be displayed at the transport bar root level")
extension InlinePicker: TransportBarElement where Body == TransportBarBodyNotSupported {
    // swiftlint:disable:next missing_docs
    public init<S>(_ title: S, selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(selection: Binding<Value>, @InlinePickerContentBuilder<Value> content: () -> InlinePickerContent<Value>) {
        fatalError()
    }
}

// swiftlint:enable fatal_error_message line_length file_types_order unavailable_function
