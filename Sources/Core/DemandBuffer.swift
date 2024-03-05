//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import DequeModule
import Foundation

/// A buffer to manage items demanded in a Combine subscription.
///
/// The buffer manages available items and the current demand, ensuring that items are delivered accordingly.
public final class DemandBuffer<T> {
    private(set) var values = Deque<T>()
    private(set) var requested: Subscribers.Demand = .none

    private let lock = NSRecursiveLock()

    /// Create a buffer containing the provided values.
    public init(_ values: [T]) {
        self.values = .init(values)
    }

    /// Append a value to the buffer.
    ///
    /// - Parameter value: The value to append.
    /// - Returns: The list of values delivered as a result of the append operation.
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

    /// Update the demand made to the buffer.
    ///
    /// - Parameter demand: The updated demand. Additive. Use `.unlimited` for unbuffered delivery.
    /// - Returns: The list of values delivered as a result of the append operation.
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
    /// Create a buffer containing the provided values.
    public convenience init(arrayLiteral elements: T...) {
        self.init(elements)
    }
}
