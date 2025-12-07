//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol TransportBarElement {
    associatedtype Body: TransportBarBody

    var body: Body { get }
}

extension TransportBarElement {
    func toMenuElement() -> UIMenuElement {
        body.toMenuElement()
    }
}
