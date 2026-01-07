//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A protocol adopted by elements displayable in a transport bar.
public protocol TransportBarElement {
    /// The body type.
    associatedtype Body: TransportBarBody

    /// The body.
    var body: Body { get }
}

extension TransportBarElement {
    func toMenuElement() -> UIMenuElement? {
        body.toMenuElement()
    }
}
