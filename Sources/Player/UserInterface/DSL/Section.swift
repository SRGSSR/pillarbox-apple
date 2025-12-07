//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

// swiftlint:disable fatal_error_message file_types_order unavailable_function

/// A section.
///
/// Sections can be used to group related items displayed by a ``Menu`` or a ``Picker``.
public struct Section<Body, Value> {
    /// The associated body.
    public let body: Body
}

// MARK: Contextual actions embedding

@available(*, unavailable, message: "Sections are not supported as contextual actions")
extension Section: ContextualActionsElement where Body == ContextualActionsBodyNotSupported, Value == Never {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: Info view actions embedding

@available(*, unavailable, message: "Sections are not supported as info view actions")
extension Section: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported, Value == Never {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: Menu embedding

/// The body of a section displayed in a menu.
public struct SectionInMenu: MenuBody {
    let title: String
    let content: SectionContent

    // swiftlint:disable:next missing_docs
    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, options: .displayInline, children: content.toMenuElements())
    }
}

extension Section: MenuElement where Body == SectionInMenu, Value == Never {
    /// Creates a section.
    ///
    /// - Parameters:
    ///   - title: The section's title.
    ///   - content: The section's content.
    @_disfavoredOverload
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        self.body = .init(title: String(title), content: content())
    }

    /// Creates a section.
    ///
    /// - Parameters:
    ///   - title: The section's title.
    ///   - content: The section's content.
    public init(title: LocalizedStringResource, @SectionContentBuilder content: () -> SectionContent) {
        self.init(title: String(localized: title), content: content)
    }

    /// Creates a section.
    ///
    /// - Parameter title: The section's title.
    public init(@SectionContentBuilder content: () -> SectionContent) {
        self.init(title: String(""), content: content)
    }
}

// MARK: Picker embedding

/// The body of a section displayed in a picker.
public struct SectionInPicker<Value>: PickerBody {
    let title: String
    let content: PickerSectionContent<Value>

    // swiftlint:disable:next missing_docs
    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        UIMenu(title: title, options: .displayInline, children: content.toMenuElements(updating: selection))
    }
}

extension Section: PickerElement where Body == SectionInPicker<Value> {
    /// Creates a section.
    ///
    /// - Parameters:
    ///   - title: The section's title.
    ///   - content: The section's content.
    @_disfavoredOverload
    public init<S>(title: S, @PickerSectionContentBuilder<Value> content: () -> PickerSectionContent<Value>) where S: StringProtocol {
        self.body = .init(title: String(title), content: content())
    }

    /// Creates a section.
    ///
    /// - Parameters:
    ///   - title: The section's title.
    ///   - content: The section's content.
    public init(title: LocalizedStringResource, @PickerSectionContentBuilder<Value> content: () -> PickerSectionContent<Value>) {
        self.init(title: String(localized: title), content: content)
    }

    /// Creates a section.
    ///
    /// - Parameter title: The section's title.
    public init(@PickerSectionContentBuilder<Value> content: () -> PickerSectionContent<Value>) {
        self.init(title: String(""), content: content)
    }
}

// MARK: Picker section embedding

@available(*, unavailable, message: "Nested sections are not supported")
extension Section: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: Section embedding

@available(*, unavailable, message: "Nested sections are not supported")
extension Section: SectionElement where Body == SectionBodyNotSupported, Value == Never {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: Transport bar embedding

@available(*, unavailable, message: "Sections cannot be displayed at the transport bar root level")
extension Section: TransportBarElement where Body == TransportBarBodyNotSupported, Value == Never {
    // swiftlint:disable:next missing_docs
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    // swiftlint:disable:next missing_docs
    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// swiftlint:enable fatal_error_message file_types_order unavailable_function
