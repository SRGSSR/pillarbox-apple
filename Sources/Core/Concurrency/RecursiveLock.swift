//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A wrapper around a recursive lock that locks around accesses to a stored object.
public class RecursiveLock<State>: @unchecked Sendable {
    private var state: State
    private let lock = NSRecursiveLock()

    /// Initializes a lock with an initial state.
    public init(initialState: State) {
        self.state = initialState
    }

    /// Perform a closure while holding the lock.
    public func withLock<R>(_ body: (inout State) throws -> R) rethrows -> R {
        try lock.withLock {
            try body(&state)
        }
    }

    /// Read the stored object through the lock.
    public func locked() -> State {
        withLock(\.self)
    }

    /// Update the stored object through the lock.
    public func setLocked(_ state: State) {
        withLock { $0 = state }
    }
}
