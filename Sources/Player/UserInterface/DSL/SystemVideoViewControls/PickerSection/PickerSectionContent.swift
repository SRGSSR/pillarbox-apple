//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A type describing the content of a picker section.
public struct PickerSectionContent<Value> {
    private let elements: [any PickerSectionElement<Value>]

    init(elements: [any PickerSectionElement<Value>] = []) {
        self.elements = elements
    }

    func toMenuElements(updating selection: Binding<Value>) -> [UIMenuElement] {
        elements.compactMap { $0.toMenuElement(updating: selection) }
    }
}
