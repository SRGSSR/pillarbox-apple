import SwiftUI

public struct Section<Body, Value> {
    public let body: Body
}

// MARK: `ContextualActions` embedding

@available(*, unavailable, message: "Sections are not supported as contextual actions")
extension Section: ContextualActionsElement where Body == ContextualActionsBodyNotSupported, Value == Never {
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: `InfoViewActions` embedding

@available(*, unavailable, message: "Sections are not supported as info view actions")
extension Section: InfoViewActionsElement where Body == InfoViewActionsBodyNotSupported, Value == Never {
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: `Menu` embedding

public struct SectionInMenu: MenuBody {
    let title: String
    let content: SectionContent

    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title, options: .displayInline, children: content.toMenuElements())
    }
}

extension Section: MenuElement where Body == SectionInMenu, Value == Never {
    @_disfavoredOverload
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        self.body = .init(title: String(title), content: content())
    }

    public init(title: LocalizedStringResource, @SectionContentBuilder content: () -> SectionContent) {
        self.init(title: String(localized: title), content: content)
    }

    public init(@SectionContentBuilder content: () -> SectionContent) {
        self.init(title: String(""), content: content)
    }
}

// MARK: `Picker` embedding

public struct SectionInPicker<Value>: PickerBody {
    let title: String
    let content: PickerSectionContent<Value>

    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        UIMenu(title: title, options: .displayInline, children: content.toMenuElements(updating: selection))
    }
}

extension Section: PickerElement where Body == SectionInPicker<Value> {
    @_disfavoredOverload
    public init<S>(title: S, @PickerSectionContentBuilder<Value> content: () -> PickerSectionContent<Value>) where S: StringProtocol {
        self.body = .init(title: String(title), content: content())
    }

    public init(title: LocalizedStringResource, @PickerSectionContentBuilder<Value> content: () -> PickerSectionContent<Value>) {
        self.init(title: String(localized: title), content: content)
    }

    public init(@PickerSectionContentBuilder<Value> content: () -> PickerSectionContent<Value>) {
        self.init(title: String(""), content: content)
    }
}

// MARK: `PickerSection` embedding

@available(*, unavailable, message: "Nested sections are not supported")
extension Section: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: `Section` embedding

@available(*, unavailable, message: "Nested sections are not supported")
extension Section: SectionElement where Body == SectionBodyNotSupported, Value == Never {
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: `TransportBar` embedding

@available(*, unavailable, message: "Sections cannot be displayed at the transport bar root level")
extension Section: TransportBarElement where Body == TransportBarBodyNotSupported, Value == Never {
    public init<S>(title: S, @SectionContentBuilder content: () -> SectionContent) where S: StringProtocol {
        fatalError()
    }

    public init(@SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}
