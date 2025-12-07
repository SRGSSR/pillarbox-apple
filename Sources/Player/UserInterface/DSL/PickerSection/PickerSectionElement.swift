//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A protocol adopted by elements displayable in a picker section.
public protocol PickerSectionElement<Value> {
    /// The body type.
    associatedtype Body: PickerSectionBody<Value>

    /// The type of value managed by the parent picker.
    associatedtype Value

    /// The body.
    var body: Body { get }
}

extension PickerSectionElement {
    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        body.toMenuElement(updating: selection)
    }
}
