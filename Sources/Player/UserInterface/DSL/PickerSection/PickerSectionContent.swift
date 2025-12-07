//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A type that describing the content of a picker section.
public struct PickerSectionContent<Value> {
    private let children: [any PickerSectionElement<Value>]

    init(children: [any PickerSectionElement<Value>] = []) {
        self.children = children
    }

    func toMenuElements(updating selection: Binding<Value>) -> [UIMenuElement] {
        children.map { $0.toMenuElement(updating: selection) }
    }
}
