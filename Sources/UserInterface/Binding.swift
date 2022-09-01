//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public extension Binding {
    /// Create a binding to an object property.
    /// - Parameters:
    ///   - object: The object to bind to.
    ///   - keyPath: The key path to bind to.
    init<T>(_ object: T, at keyPath: ReferenceWritableKeyPath<T, Value>) {
        self.init(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0 }
        )
    }

    /// Create a binding to an object nullable property.
    /// - Parameters:
    ///   - object: The object to bind to.
    ///   - keyPath: The key path to bind to.
    ///   - defaultValue: The default value to use when the property is `nil`.
    init<T>(_ object: T, at keyPath: ReferenceWritableKeyPath<T, Value?>, defaultValue: Value) {
        self.init(
            get: { object[keyPath: keyPath] ?? defaultValue },
            set: { object[keyPath: keyPath] = $0 }
        )
    }
}
