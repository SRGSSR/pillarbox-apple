//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public struct PickerBodyNotSupported<Value>: PickerBody {
    // swiftlint:disable:next unavailable_function
    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

public protocol PickerBody<Value> {
    associatedtype Value

    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement
}
