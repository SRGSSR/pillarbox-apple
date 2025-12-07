//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import UIKit

/// A body for elements not supporting wrapping in a section.
public struct SectionBodyNotSupported: SectionBody {
    // swiftlint:disable:next missing_docs unavailable_function
    public func toMenuElement() -> UIMenuElement {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

/// A protocol describing the body of elements wrapped in a section.
public protocol SectionBody {
    /// Converts the body to a menu element.
    func toMenuElement() -> UIMenuElement
}
