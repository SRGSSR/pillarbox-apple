//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that describing the content of a transport bar.
public struct TransportBarContent {
    private let elements: [any TransportBarElement]

    init(elements: [any TransportBarElement] = []) {
        self.elements = elements
    }

    func toMenuElements() -> [UIMenuElement] {
        elements.compactMap { $0.toMenuElement() }
    }
}
