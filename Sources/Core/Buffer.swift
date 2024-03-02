//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class Buffer<T> {
    let size: Int

    private(set) var values: [T] = []

    init(size: Int) {
        assert(size >= 0)
        self.size = size
    }

    func append(_ t: T) {
        values.append(t)
        values = values.suffix(size)
    }
}
