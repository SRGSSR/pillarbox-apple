import SwiftUI

public protocol PickerBody<Value> {
    associatedtype Value

    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement
}

public struct PickerBodyNotSupported<Value>: PickerBody {
    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        fatalError()
    }
}
