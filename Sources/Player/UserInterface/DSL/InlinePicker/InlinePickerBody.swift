//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A body for elements not supporting wrapping in an inline picker.
public struct InlinePickerBodyNotSupported<Value>: InlinePickerBody {
    // swiftlint:disable:next missing_docs unavailable_function
    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

/// A protocol describing the body of elements wrapped in an inline picker.
public protocol InlinePickerBody<Value> {
    /// The type of value managed by the picker.
    associatedtype Value

    /// Converts the body to a menu element.
    ///
    /// - Parameter selection: A binding to the value managed by the picker.
    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement
}
