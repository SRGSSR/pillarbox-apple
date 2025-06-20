//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import os

/// A thread-safe buffer able to hold a maximum number of values.
final class LimitedBuffer<T> {
    private let size: Int
    private let state = OSAllocatedUnfairLock(initialState: State(values: []))

    var values: [T] {
        state.withLock(\.values)
    }

    init(size: Int) {
        assert(size >= 0)
        self.size = size
    }

    func append(_ t: T) {
        guard size > 0 else { return }
        state.withLock { state in
            state.append(t, withLimit: size)
        }
    }
}

private extension LimitedBuffer {
    struct State {
        private(set) var values = [T]()

        mutating func append(_ t: T, withLimit limit: Int) {
            values.append(t)
            if values.count > limit {
                values.removeFirst(values.count - limit)
            }
        }
    }
}
