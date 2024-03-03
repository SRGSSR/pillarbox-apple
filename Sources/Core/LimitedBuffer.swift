//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// A buffer able to hold a maximum number of values.
final class LimitedBuffer<T> {
    private let size: Int
    private(set) var values: [T] = []

    init(size: Int) {
        assert(size >= 0)
        self.size = size
    }

    func append(_ t: T) {
        guard size > 0 else { return }
        values.append(t)
        values = values.suffix(size)
    }
}
