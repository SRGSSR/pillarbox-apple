//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

public class RecursiveLock<State>: @unchecked Sendable {
    private var state: State
    private let lock = NSRecursiveLock()

    public init(initialState: State) {
        self.state = initialState
    }

    public func withLock<R>(_ body: (inout State) throws -> R) rethrows -> R {
        try lock.withLock {
            try body(&state)
        }
    }
}
