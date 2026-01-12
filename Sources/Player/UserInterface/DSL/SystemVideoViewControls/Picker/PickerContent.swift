//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A type describing the content of a picker.
public struct PickerContent<Value> {
    private let elements: [any PickerElement<Value>]

    init(elements: [any PickerElement<Value>] = []) {
        self.elements = elements
    }

    func toMenuElements(updating selection: Binding<Value>) -> [UIMenuElement] {
        elements.compactMap { $0.toMenuElement(updating: selection) }
    }
}
