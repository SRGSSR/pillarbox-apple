//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A protocol adopted by elements displayable in a menu.
public protocol MenuElement {
    /// The body type.
    associatedtype Body: MenuBody

    /// The body.
    var body: Body { get }
}

extension MenuElement {
    func toMenuElement() -> UIMenuElement? {
        body.toMenuElement()
    }
}
