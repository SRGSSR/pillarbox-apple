//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that describing the content of a menu.
public struct MenuContent {
    private let elements: [any MenuElement]

    init(elements: [any MenuElement] = []) {
        self.elements = elements
    }

    func toMenuElements() -> [UIMenuElement] {
        elements.compactMap { $0.toMenuElement() }
    }
}
