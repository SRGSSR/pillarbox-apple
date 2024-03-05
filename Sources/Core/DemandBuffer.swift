//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import DequeModule
import Foundation

public final class DemandBuffer<T> {
    private(set) var values = Deque<T>()
    private(set) var requested: Subscribers.Demand = .none

    private let lock = NSRecursiveLock()

    public init(_ values: [T]) {
        self.values = .init(values)
    }

    public func append(_ value: T) -> [T] {
        withLock(lock) {
            switch requested {
            case .unlimited:
                return [value]
            default:
                values.append(value)
                return flush()
            }
        }
    }

    public func request(_ demand: Subscribers.Demand) -> [T] {
        withLock(lock) {
            requested += demand
            return flush()
        }
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
    public convenience init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}
