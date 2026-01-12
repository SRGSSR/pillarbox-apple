//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type describing the content of a section.
public struct SectionContent {
    private let elements: [any SectionElement]

    init(elements: [any SectionElement] = []) {
        self.elements = elements
    }

    func toMenuElements() -> [UIMenuElement] {
        elements.compactMap { $0.toMenuElement() }
    }
}
