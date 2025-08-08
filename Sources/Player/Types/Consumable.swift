//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

final class Consumable<T> {
    private var value: T?

    init(value: T?) {
        self.value = value
    }

    func store(_ value: T) {
        self.value = value
    }

    func take() -> T? {
        defer {
            value = nil
        }
        return value
    }
}
