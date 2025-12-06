import SwiftUI

public protocol PickerElement<Value> {
    associatedtype Body: PickerBody<Value>
    associatedtype Value

    var body: Body { get }
}

extension PickerElement {
    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        body.toMenuElement(updating: selection)
    }
}
