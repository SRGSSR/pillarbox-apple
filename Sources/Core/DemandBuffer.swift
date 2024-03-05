//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import DequeModule

final class DemandBuffer<T> {
    private(set) var values = Deque<T>()
    private(set) var requested: Subscribers.Demand = .none

    init(_ values: [T]) {
        self.values = .init(values)
    }

    func append(_ value: T) -> [T] {
        switch requested {
        case .unlimited:
            return [value]
        default:
            values.append(value)
            return flush()
        }
    }

    func request(_ demand: Subscribers.Demand) -> [T] {
        requested += demand
        return flush()
    }

    private func flush() -> [T] {
        var values = [T]()
        while requested > 0, let value = self.values.popFirst() {
            values.append(value)
            requested -= 1
        }
        return values
    }
}

extension DemandBuffer: ExpressibleByArrayLiteral {
    convenience init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}
