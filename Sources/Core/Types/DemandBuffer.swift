//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import DequeModule
import Foundation

/// A thread-safe buffer managing items demanded by a `Subscriber` in a Combine `Subscription`.
///
/// The buffer can be used when implementing a subscription so that items can be kept if needed while waiting for a
/// subscriber demand.
public final class DemandBuffer<T> {
    private(set) var values = Deque<T>()
    private(set) var requested: Subscribers.Demand = .none

    private let lock = NSLock()

    /// Creates a buffer initially containing the provided values.
    public init(_ values: [T]) {
        self.values = .init(values)
    }

    /// Appends a value to the buffer, returning values that should be returned to the subscriber as a result.
    public func append(_ value: T) -> [T] {
        lock.withLock {
            switch requested {
            case .unlimited:
                return [value]
            default:
                values.append(value)
                return flush()
            }
        }
    }

    /// Updates the demand, returning values that should be returned to the subscriber as a result.
    public func request(_ demand: Subscribers.Demand) -> [T] {
        lock.withLock {
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
    /// Creates a buffer initially containing the provided values.
    public convenience init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}
