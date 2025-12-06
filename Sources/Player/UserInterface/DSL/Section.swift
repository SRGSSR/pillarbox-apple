import SwiftUI

public struct Section<Body, Value> {
    public let body: Body
}

// MARK: `Menu` embedding

public struct SectionInMenu: MenuBody {
    let title: String?
    let content: SectionContent

    public func toMenuElement() -> UIMenuElement {
        UIMenu(title: title ?? "", options: .displayInline, children: content.toMenuElements())
    }
}

extension Section: MenuElement where Body == SectionInMenu, Value == Never {
    public init(title: String? = nil, @SectionContentBuilder content: () -> SectionContent) {
        self.body = .init(title: title, content: content())
    }
}

// MARK: `Section` embedding

extension Section: SectionElement where Body == SectionBodyNotSupported, Value == Never {
    @available(*, unavailable, message: "Nested sections are not supported")
    public init(title: String? = nil, @SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: `Picker` embedding

public struct SectionInPicker<Value>: PickerBody {
    let title: String?
    let content: PickerSectionContent<Value>

    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        UIMenu(title: title ?? "", options: .displayInline, children: content.toMenuElements(updating: selection))
    }
}

extension Section: PickerElement where Body == SectionInPicker<Value> {
    public init(title: String? = nil, @PickerSectionContentBuilder<Value> content: () -> PickerSectionContent<Value>) {
        self.body = .init(title: title, content: content())
    }
}

// MARK: `PickerSection` embedding

extension Section: PickerSectionElement where Body == PickerSectionBodyNotSupported<Value> {
    @available(*, unavailable, message: "Nested sections are not supported")
    public init(title: String? = nil, @SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}

// MARK: `TransportBar` embedding

extension Section: TransportBarElement where Body == TransportBarBodyNotSupported, Value == Never {
    @available(*, unavailable, message: "Sections cannot be displayed at the transport bar root level")
    public init(title: String? = nil, @SectionContentBuilder content: () -> SectionContent) {
        fatalError()
    }
}
