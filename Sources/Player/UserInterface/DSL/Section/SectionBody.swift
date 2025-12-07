//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

public struct SectionBodyNotSupported: SectionBody {
    // swiftlint:disable:next unavailable_function
    public func toMenuElement() -> UIMenuElement {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

public protocol SectionBody {
    func toMenuElement() -> UIMenuElement
}
