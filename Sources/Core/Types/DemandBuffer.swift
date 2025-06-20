//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import DequeModule
import Foundation
import os

/// A thread-safe buffer managing items demanded by a `Subscriber` in a Combine `Subscription`.
///
/// The buffer can be used when implementing a subscription so that items can be kept if needed while waiting for a
/// subscriber demand.
public final class DemandBuffer<T> {
    private var _values = Deque<T>()
    private var _requested: Subscribers.Demand = .none

    private let lock = OSAllocatedUnfairLock()

    var values: Deque<T> {
        lock.withLock { _values }
    }

    var requested: Subscribers.Demand {
        lock.withLock { _requested }
    }

    /// Creates a buffer initially containing the provided values.
    public init(_ values: [T]) {
        _values = .init(values)
    }

    /// Appends a value to the buffer, returning values that should be returned to the subscriber as a result.
    public func append(_ value: T) -> [T] {
        lock.withLock {
            switch _requested {
            case .unlimited:
                return [value]
            default:
                _values.append(value)
                return flush()
            }
        }
    }

    /// Updates the demand, returning values that should be returned to the subscriber as a result.
    public func request(_ demand: Subscribers.Demand) -> [T] {
        lock.withLock {
            _requested += demand
            return flush()
        }
    }

    private func flush() -> [T] {
        var values = [T]()
        while _requested > 0, let value = _values.popFirst() {
            values.append(value)
            _requested -= 1
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
