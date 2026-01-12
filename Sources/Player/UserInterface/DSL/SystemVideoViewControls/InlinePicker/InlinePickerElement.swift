//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A protocol adopted by elements displayable in an inline picker.
public protocol InlinePickerElement<Value> {
    /// The body type.
    associatedtype Body: InlinePickerBody<Value>

    /// The type of value managed by the picker.
    associatedtype Value

    /// The body.
    var body: Body { get }
}

extension InlinePickerElement {
    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        body.toMenuElement(updating: selection)
    }
}
