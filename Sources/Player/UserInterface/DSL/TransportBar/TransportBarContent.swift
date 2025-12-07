//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct TransportBarContent {
    private let children: [any TransportBarElement]

    init(children: [any TransportBarElement] = []) {
        self.children = children
    }

    func toMenuElements() -> [UIMenuElement] {
        children.map { $0.toMenuElement() }
    }
}
