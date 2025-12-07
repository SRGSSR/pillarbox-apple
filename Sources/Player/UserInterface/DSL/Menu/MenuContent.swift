//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that describing the content of a menu.
public struct MenuContent {
    private let children: [any MenuElement]

    init(children: [any MenuElement] = []) {
        self.children = children
    }

    func toMenuElements() -> [UIMenuElement] {
        children.map { $0.toMenuElement() }
    }
}
