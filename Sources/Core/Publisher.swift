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
}

public extension Publisher {
    /// Safely receives elements from the upstream on the main thread.
    ///
    /// - Returns: A publisher delivering elements on the main thread.
    func receiveOnMainThread() -> AnyPublisher<Output, Failure> {
        flatMap { output in
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
        .eraseToAnyPublisher()
    }

    /// Delays delivery of all output to the downstream receiver by a specified amount of time on a particular scheduler.
    ///
    /// - Parameters:
    ///   - interval: The amount of time to delay.
    ///   - tolerance: The allowed tolerance in delivering delayed events. The `Delay` publisher may deliver elements 
    ///     this much sooner or later than the interval specifies.
    ///   - scheduler: The scheduler to deliver the delayed events.
    ///   - options: Options relevant to the scheduler’s behavior.
    /// - Returns: A publisher that delays delivery of elements and completion to the downstream receiver.
    ///
    /// If the `interval` is zero the value is published synchronously, not on the specified scheduler.
    func delayIfNeeded<S>(
        for interval: S.SchedulerTimeType.Stride,
        tolerance: S.SchedulerTimeType.Stride? = nil,
        scheduler: S,
        options: S.SchedulerOptions? = nil
    ) -> AnyPublisher<Output, Failure> where S: Scheduler {
        flatMap { output in
            if interval != 0 {
                return Just(output)
                    .delay(for: interval, tolerance: tolerance, scheduler: scheduler, options: options)
                    .eraseToAnyPublisher()
            }
            else {
                return Just(output).eraseToAnyPublisher()
            }
        }
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

public extension Publisher {
    /// Shares the output (including recent values) of an upstream publisher with multiple subscribers.
    ///
    /// - Parameter bufferSize: The maximum number of values that must be buffered.
    ///
    /// Upon subscription new subscribers automatically receive recent values available from the buffer, as well as
    /// any relevant completion.
    func share(replay bufferSize: Int) -> AnyPublisher<Output, Failure> {
        multicast(subject: ReplaySubject(bufferSize: bufferSize))
            .autoconnect()
            .eraseToAnyPublisher()
    }
}

public extension Publisher {
    /// Measure the date interval between consecutive outputs.
    ///
    /// - Parameter measure: A closure called for each output delivered upstream.
    ///
    /// The first measurement is made relative to the time at which subscription to the publisher was made.
    func measureDateInterval(perform measure: @escaping (DateInterval) -> Void) -> AnyPublisher<Output, Failure> {
        var startDate: Date?
        return handleEvents(
            receiveSubscription: { _ in
                startDate = Date()
            },
            receiveOutput: { _ in
                guard let start = startDate else { return }
                let end = Date()
                measure(.init(start: start, end: end))
                startDate = end
            }
        )
        .eraseToAnyPublisher()
    }

    /// Measure the date interval between consecutive outputs filtered by a condition.
    ///
    /// - Parameters
    ///    - measure: A closure called for each matching output delivered upstream.
    ///    - condition: A closure called to filter matching outputs.
    ///
    /// The first measurement is made relative to the time at which subscription to the publisher was made.
    func measureDateInterval(perform measure: @escaping (DateInterval) -> Void, when condition: @escaping (Output) -> Bool) -> AnyPublisher<Output, Failure> {
        var startDate: Date?
        return handleEvents(
            receiveSubscription: { _ in
                startDate = Date()
            },
            receiveOutput: { output in
                guard let start = startDate, condition(output) else { return }
                let end = Date()
                measure(.init(start: start, end: end))
                startDate = end
            }
        )
        .eraseToAnyPublisher()
    }

    /// Measure the date interval until an output matches a given condition for the first time.
    ///
    /// - Parameters
    ///    - measure: A closure called for each output delivered upstream.
    ///    - condition: A closure called to find the first matching output.
    ///
    /// The measurement is made relative to the time at which subscription to the publisher was made.
    func measureFirstDateInterval(
        perform measure: @escaping (DateInterval) -> Void,
        when condition: @escaping (Output) -> Bool
    ) -> AnyPublisher<Output, Failure> {
        var startDate: Date?
        return handleEvents(
            receiveSubscription: { _ in
                startDate = Date()
            },
            receiveOutput: { output in
                guard let start = startDate, condition(output) else { return }
                let end = Date()
                measure(.init(start: start, end: end))
                startDate = nil
            }
        )
        .eraseToAnyPublisher()
    }
}
