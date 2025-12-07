//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public struct PickerContent<Value> {
    private let children: [any PickerElement<Value>]

    init(children: [any PickerElement<Value>] = []) {
        self.children = children
    }

    func toMenuElements(updating selection: Binding<Value>) -> [UIMenuElement] {
        children.map { $0.toMenuElement(updating: selection) }
    }
}
