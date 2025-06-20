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
    private let state: OSAllocatedUnfairLock<State>

    var values: Deque<T> {
        state.withLock(\.values)
    }

    var requested: Subscribers.Demand {
        state.withLock(\.requested)
    }

    /// Creates a buffer initially containing the provided values.
    public init(_ values: [T]) {
        state = .init(initialState: .init(values: values))
    }

    /// Appends a value to the buffer, returning values that should be returned to the subscriber as a result.
    public func append(_ value: T) -> [T] {
        state.withLock { state in
            switch state.requested {
            case .unlimited:
                return [value]
            default:
                state.append(value)
                return state.flush()
            }
        }
    }

    /// Updates the demand, returning values that should be returned to the subscriber as a result.
    public func request(_ demand: Subscribers.Demand) -> [T] {
        state.withLock { state in
            state.request(demand)
        }
    }
}

extension DemandBuffer {
    private struct State {
        var values: Deque<T>
        var requested: Subscribers.Demand

        init(values: [T]) {
            self.values = .init(values)
            self.requested = .none
        }

        mutating func append(_ value: T) {
            values.append(value)
        }

        mutating func request(_ demand: Subscribers.Demand) -> [T] {
            requested += demand
            return flush()
        }

        mutating func flush() -> [T] {
            var flushedValues = [T]()
            while requested > 0, let value = values.popFirst() {
                flushedValues.append(value)
                requested -= 1
            }
            return flushedValues
        }
    }
}

extension DemandBuffer: ExpressibleByArrayLiteral {
    /// Creates a buffer initially containing the provided values.
    public convenience init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}
