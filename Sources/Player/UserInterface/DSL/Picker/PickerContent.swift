//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A type that describing the content of a picker.
public struct PickerContent<Value> {
    private let children: [any PickerElement<Value>]

    init(children: [any PickerElement<Value>] = []) {
        self.children = children
    }

    func toMenuElements(updating selection: Binding<Value>) -> [UIMenuElement] {
        children.compactMap { $0.toMenuElement(updating: selection) }
    }
}
