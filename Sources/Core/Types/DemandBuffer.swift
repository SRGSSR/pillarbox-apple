//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import DequeModule
import Foundation
import os

private final class UnsafeDemandBuffer<T> {
    private(set) var values: Deque<T>
    private(set) var requested: Subscribers.Demand

    init(values: [T]) {
        self.values = .init(values)
        self.requested = .none
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

    func flush() -> [T] {
        var flushedValues = [T]()
        while requested > 0, let value = values.popFirst() {
            flushedValues.append(value)
            requested -= 1
        }
        return flushedValues
    }
}

/// A thread-safe buffer managing items demanded by a `Subscriber` in a Combine `Subscription`.
///
/// The buffer can be used when implementing a subscription so that items can be kept if needed while waiting for a
/// subscriber demand.
public final class DemandBuffer<T> {
    private let buffer: OSAllocatedUnfairLock<UnsafeDemandBuffer<T>>

    var values: Deque<T> {
        buffer.withLock(\.values)
    }

    var requested: Subscribers.Demand {
        buffer.withLock(\.requested)
    }

    /// Creates a buffer initially containing the provided values.
    public init(_ values: [T]) {
        buffer = .init(initialState: .init(values: values))
    }

    /// Appends a value to the buffer, returning values that should be returned to the subscriber as a result.
    public func append(_ value: T) -> [T] {
        buffer.withLock { buffer in
            buffer.append(value)
        }
    }

    /// Updates the demand, returning values that should be returned to the subscriber as a result.
    public func request(_ demand: Subscribers.Demand) -> [T] {
        buffer.withLock { buffer in
            buffer.request(demand)
        }
    }
}

extension DemandBuffer: ExpressibleByArrayLiteral {
    /// Creates a buffer initially containing the provided values.
    public convenience init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}
