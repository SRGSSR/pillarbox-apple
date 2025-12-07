//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A protocol adopted by elements displayable in a section.
public protocol SectionElement {
    /// The body type.
    associatedtype Body: SectionBody

    /// The body.
    var body: Body { get }
}

extension SectionElement {
    func toMenuElement() -> UIMenuElement {
        body.toMenuElement()
    }
}
