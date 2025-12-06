import SwiftUI

public protocol PickerSectionBody<Value> {
    associatedtype Value

    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement
}

public struct PickerSectionBodyNotSupported<Value>: PickerSectionBody {
    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        fatalError()
    }
}
