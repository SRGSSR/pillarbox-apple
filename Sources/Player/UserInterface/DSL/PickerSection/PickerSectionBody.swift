//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public struct PickerSectionBodyNotSupported<Value>: PickerSectionBody {
    // swiftlint:disable:next unavailable_function
    public func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement {
        // swiftlint:disable:next fatal_error_message
        fatalError()
    }
}

public protocol PickerSectionBody<Value> {
    associatedtype Value

    func toMenuElement(updating selection: Binding<Value>) -> UIMenuElement
}
