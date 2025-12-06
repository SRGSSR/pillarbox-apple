import SwiftUI

public struct PickerSectionContent<Value> {
    private let children: [any PickerSectionElement<Value>]

    init(children: [any PickerSectionElement<Value>] = []) {
        self.children = children
    }

    func toMenuElements(updating selection: Binding<Value>) -> [UIMenuElement] {
        children.map { $0.toMenuElement(updating: selection) }
    }
}
