import SwiftUI

public protocol PickerSectionElement<Value> {
    associatedtype Body: PickerSectionBody<Value>
    associatedtype Value

    var body: Body { get }
}

extension PickerSectionElement {
    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        body.toMenuElement(updating: selection)
    }
}
