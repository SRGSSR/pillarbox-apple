//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A type that describing the content of an inline picker.
public struct InlinePickerContent<Value> {
    private let children: [any InlinePickerElement<Value>]

    init(children: [any InlinePickerElement<Value>] = []) {
        self.children = children
    }

    func toMenuElements(updating selection: Binding<Value>) -> [UIMenuElement] {
        children.map { $0.toMenuElement(updating: selection) }
    }
}
