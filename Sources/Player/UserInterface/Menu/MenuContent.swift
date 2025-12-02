//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that contains a menu.
public struct MenuContent {
    let children: [UIMenuElement]

    init(children: [UIMenuElement] = []) {
        self.children = children
    }
}
