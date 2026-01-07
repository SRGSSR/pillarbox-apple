//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A type that describing the content of an inline picker.
public struct InlinePickerContent<Value> {
    private let elements: [any InlinePickerElement<Value>]

    init(elements: [any InlinePickerElement<Value>] = []) {
        self.elements = elements
    }

    func toMenuElements(updating selection: Binding<Value>) -> [UIMenuElement] {
        elements.map { $0.toMenuElement(updating: selection) }
    }
}
