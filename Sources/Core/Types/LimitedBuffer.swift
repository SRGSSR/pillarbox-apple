//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import os

private final class UnsafeLimitedBuffer<T> {
    private let size: Int

    private(set) var values = [T]()

    init(size: Int) {
        assert(size >= 0)
        self.size = size
    }

    func append(_ t: T) {
        guard size > 0 else { return }
        values.append(t)
        if values.count > size {
            values.removeFirst(values.count - size)
        }
    }
}

/// A thread-safe buffer able to hold a maximum number of values.
final class LimitedBuffer<T> {
    private let buffer: OSAllocatedUnfairLock<UnsafeLimitedBuffer<T>>

    var values: [T] {
        buffer.withLock(\.values)
    }

    init(size: Int) {
        buffer = .init(initialState: .init(size: size))
    }

    func append(_ t: T) {
        buffer.withLock { buffer in
            buffer.append(t)
        }
    }
}
