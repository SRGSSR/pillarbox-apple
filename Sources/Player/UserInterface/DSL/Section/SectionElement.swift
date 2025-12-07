//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public protocol SectionElement {
    associatedtype Body: SectionBody

    var body: Body { get }
}

extension SectionElement {
    func toMenuElement() -> UIMenuElement {
        body.toMenuElement()
    }
}
