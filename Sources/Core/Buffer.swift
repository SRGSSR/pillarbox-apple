//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

final class Buffer<T> {
    let size: Int

    private(set) var elements: [T] = []

    init(size: Int) {
        self.size = size
    }

    func append(_ t: T) {
        elements.append(t)
        elements = elements.suffix(size)
    }
}
