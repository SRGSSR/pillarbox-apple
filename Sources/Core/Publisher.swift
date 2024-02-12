//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

// Borrowed from https://stackoverflow.com/a/67133582/760435

public extension Publisher {
    /// Includes the current element as well as the previous element from the upstream publisher in a tuple where the
    /// previous element is optional.
    ///
    /// - Returns: A publisher of a tuple of the previous and current elements from the upstream publisher.
    ///
    /// The first time the upstream publisher emits an element, the previous element will be `nil`.
    ///
    /// ```swift
    /// let range = (1...5)
    /// cancellable = range.publisher
    ///     .withPrevious()
    ///     .sink { print ("(\($0.previous), \($0.current))", terminator: " ") }
    /// // Prints: "(nil, 1) (Optional(1), 2) (Optional(2), 3) (Optional(3), 4) (Optional(4), 5) ".
    /// ```
    func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
        scan(Optional<(Output?, Output)>.none) { ($0?.1, $1) }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    /// Includes the current element as well as the previous element from the upstream publisher in a tuple where the
    /// previous element is not optional.
    ///
    /// - Parameter initialPreviousValue: The initial value to use as the previous value when the upstream publisher
    ///   emits for the first time.
    /// - Returns: A publisher of a tuple of the previous and current elements from the upstream publisher.
    ///
    /// The first time the upstream publisher emits an element, the previous element will be the `initialPreviousValue`.
    ///
    /// ```swift
    /// let range = (1...5)
    /// cancellable = range.publisher
    ///     .withPrevious(0)
    ///     .sink { print ("(\($0.previous), \($0.current))", terminator: " ") }
    /// // Prints: "(0, 1) (1, 2) (2, 3) (3, 4) (4, 5) ".
    /// ```
    func withPrevious(_ initialPreviousValue: Output) -> AnyPublisher<(previous: Output, current: Output), Failure> {
        scan((initialPreviousValue, initialPreviousValue)) { ($0.1, $1) }.eraseToAnyPublisher()
    }
}

public extension Publisher {
    /// Captures an object weakly and provides one of its properties as additional output.
    ///
    /// - Parameters:
    ///   - other: The object to weakly capture.
    ///   - keyPath: The key path for which to provide values.
    /// - Returns: A publisher combining the original output with values from the weakly captured object at the
    ///   specified key path.
    ///
    /// Does not emit when the object is `nil`.
    func weakCapture<T, V>(_ other: T?, at keyPath: KeyPath<T, V>) -> AnyPublisher<(Output, V), Failure> where T: AnyObject {
        compactMap { [weak other] output -> (Output, V)? in
            guard let other else { return nil }
            return (output, other[keyPath: keyPath])
        }
        .eraseToAnyPublisher()
    }

    /// Captures an object weakly and provides it as additional output.
    ///
    /// - Parameter other: The object to weakly capture.
    /// - Returns: A publisher combining the original output with the weakly captured object (if not `nil`).
    ///
    /// Does not emit when the object is `nil`.
    func weakCapture<T>(_ other: T?) -> AnyPublisher<(Output, T), Failure> where T: AnyObject {
        weakCapture(other, at: \T.self)
    }

    /// Safely receives elements from the upstream on the main thread.
    ///
    /// - Returns: A publisher delivering elements on the main thread.
    func receiveOnMainThread() -> AnyPublisher<Output, Failure> {
        map { output in
            // `receive(on: DispatchQueue.main)` defers execution if already on the main thread. Do nothing in this case.
            if Thread.isMainThread {
                return Just(output)
                    .eraseToAnyPublisher()
            }
            else {
                return Just(output)
                    .receive(on: DispatchQueue.main)
                    .eraseToAnyPublisher()
            }
        }
        .switchToLatest()
        .eraseToAnyPublisher()
    }
}

public extension Publisher {
    /// Slices a publisher output to emit equatable values found at a specific path downstream, removing any duplicates
    /// in the process.
    ///
    /// - Parameter keyPath: The key path to extract
    /// - Returns: A publisher emitting values at the specified key path.
    func slice<T>(at keyPath: KeyPath<Output, T>) -> AnyPublisher<T, Failure> where T: Equatable {
        map(keyPath)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    /// Make the upstream publisher wait until a second signal publisher emits some value.
    /// 
    /// - Parameter signal: The signal publisher.
    /// - Returns: A publisher emitting values after the signal publisher emits a value.
    func wait<S>(untilOutputFrom signal: S) -> AnyPublisher<Output, Failure> where S: Publisher, S.Failure == Never {
        prepend(
            Empty(completeImmediately: false)
                .prefix(untilOutputFrom: signal)
        )
        .eraseToAnyPublisher()
    }
}

// Borrowed from https://www.swiftbysundell.com/articles/combine-self-cancellable-memory-management/
public extension Publisher where Failure == Never {
    /// Assigns each element from a publisher to a property on a weak object.
    ///
    /// - Parameters:
    ///   - keyPath: A key path that indicates the property to assign.
    ///   - object: The object that contains the property. The subscriber assigns the object’s property every time it 
    ///     receives a new value.
    /// - Returns: An `AnyCancellable` instance which can be used to cancel the subscription.
    func weakAssign<T: AnyObject>(to keyPath: ReferenceWritableKeyPath<T, Output>, on object: T) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
