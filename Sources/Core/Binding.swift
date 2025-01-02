//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import SwiftUI

public extension Binding {
    /// Creates a binding to an object key path.
    /// 
    /// - Parameters:
    ///   - object: The object to bind to.
    ///   - keyPath: The key path to bind to.
    init<T>(_ object: T, at keyPath: ReferenceWritableKeyPath<T, Value> & Sendable) where T: Sendable {
        self.init(
            get: { object[keyPath: keyPath] },
            set: { object[keyPath: keyPath] = $0 }
        )
    }
}
