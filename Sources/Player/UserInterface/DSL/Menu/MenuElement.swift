//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol MenuElement {
    associatedtype Body: MenuBody

    var body: Body { get }
}

extension MenuElement {
    func toMenuElement() -> UIMenuElement {
        body.toMenuElement()
    }
}
