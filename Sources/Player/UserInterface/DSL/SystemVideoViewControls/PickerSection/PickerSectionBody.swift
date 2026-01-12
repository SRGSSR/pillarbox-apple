//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

/// A body for elements not supporting wrapping in a picker section.
public struct PickerSectionBodyNotSupported<Value>: PickerSectionBody {
    // swiftlint:disable:next missing_docs unavailable_function
    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement? {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

/// A protocol describing the body of elements wrapped in a picker section.
public protocol PickerSectionBody<Value> {
    /// The type of value managed by the parent picker.
    associatedtype Value

    /// Converts the body to a menu element.
    ///
    /// - Parameter selection: A binding to the value managed by the parent picker.
    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement?
}
