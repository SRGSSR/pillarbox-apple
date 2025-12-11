//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A type that describing the content of a section.
public struct SectionContent {
    private let children: [any SectionElement]

    init(children: [any SectionElement] = []) {
        self.children = children
    }

    func toMenuElements() -> [UIMenuElement] {
        children.compactMap { $0.toMenuElement() }
    }
}
