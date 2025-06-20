//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import os

/// A thread-safe buffer able to hold a maximum number of values.
final class LimitedBuffer<T> {
    private let size: Int
    private let _values = OSAllocatedUnfairLock(initialState: [T]())

    var values: [T] {
        _values.withLock { $0 }
    }

    init(size: Int) {
        assert(size >= 0)
        self.size = size
    }

    func append(_ t: T) {
        guard size > 0 else { return }
        _values.withLock { values in
            values.append(t)
            values = values.suffix(size)
        }
    }
}
