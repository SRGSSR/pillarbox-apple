//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A protocol adopted by elements displayable in a picker.
public protocol PickerElement<Value> {
    /// The body type.
    associatedtype Body: PickerBody<Value>

    /// The type of value managed by the picker.
    associatedtype Value

    /// The body.
    var body: Body { get }
}

extension PickerElement {
    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement? {
        body.toMenuElement(updating: selection)
    }
}
