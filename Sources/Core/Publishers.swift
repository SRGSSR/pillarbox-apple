//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

public extension Publishers {
    /// Accumulates the results of a list of publishers and delivers them as a stream of arrays containing the latest
    /// values in publisher order.
    ///
    /// The first value is emitted once all publishers have at least emitted a value once.
    /// - Parameter publishers: The publishers to accumulate.
    /// - Returns: The resulting publisher.
    static func AccumulateLatestMany<Upstream>(
        _ publishers: Upstream...
    ) -> AnyPublisher<[Upstream.Output], Upstream.Failure> where Upstream: Publisher {
        AccumulateLatestMany(publishers)
    }

    /// Accumulates the results of a list of publishers and delivers them as a stream of arrays containing the latest
    /// values in publisher order.
    ///
    /// The first array is emitted once all publishers have at least emitted a value once.
    /// - Parameter publishers: The publishers to accumulate.
    /// - Returns: The resulting publisher.
    static func AccumulateLatestMany<Upstream, S>(
        _ publishers: S
    ) -> AnyPublisher<[Upstream.Output], Upstream.Failure> where Upstream: Publisher, S: Swift.Sequence, S.Element == Upstream {
        let publishersArray = Array(publishers)
        switch publishersArray.count {
        case 0:
            return Just([])
                .setFailureType(to: Upstream.Failure.self)
                .eraseToAnyPublisher()
        case 1:
            return publishersArray[0]
                .map { [$0] }
                .eraseToAnyPublisher()
        case 2:
            return Publishers.CombineLatest(publishersArray[0], publishersArray[1])
                .map { [$0, $1] }
                .eraseToAnyPublisher()
        case 3:
            return Publishers.CombineLatest3(publishersArray[0], publishersArray[1], publishersArray[2])
                .map { [$0, $1, $2] }
                .eraseToAnyPublisher()
        default:
            let half = publishersArray.count / 2
            return Publishers.CombineLatest(
                AccumulateLatestMany(Array(publishersArray[0..<half])),
                AccumulateLatestMany(Array(publishersArray[half..<publishersArray.count]))
            )
            .map { $0 + $1 }
            .eraseToAnyPublisher()
        }
    }
}

public extension Publishers {
    /// Makes the upstream publisher publish each time another signal publisher emits some value.
    /// - Parameters:
    ///   - signal: The signal to listen to. If `nil` the upstream publisher will never publish.
    ///   - publisher: The publisher to execute.
    /// - Returns: The resulting publisher.
    static func Publish<S, P>(
        onOutputFrom signal: S?,
        _ publisher: @escaping () -> P
    ) -> AnyPublisher<P.Output, P.Failure> where S: Publisher, P: Publisher, S.Failure == Never {
        guard let signal else {
            return Empty<P.Output, P.Failure>().eraseToAnyPublisher()
        }
        return signal
            .map { _ in publisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    /// Makes the upstream publisher execute once and repeat each time another signal publisher emits some value.
    /// - Parameters:
    ///   - signal: The signal to listen to. If `nil` the upstream publisher executes only once.
    ///   - publisher: The publisher to execute.
    /// - Returns: The resulting publisher.
    static func PublishAndRepeat<S, P>(
        onOutputFrom signal: S?,
        _ publisher: @escaping () -> P
    ) -> AnyPublisher<P.Output, P.Failure> where S: Publisher, P: Publisher, S.Failure == Never {
        guard let signal else {
            return publisher().eraseToAnyPublisher()
        }

        // Use `prepend(_:)` to trigger an initial update
        // Inspired from https://stackoverflow.com/questions/66075000/swift-combine-publishers-where-one-hasnt-sent-a-value-yet
        return signal
            .map { _ in }
            .prepend(())
            .map { _ in publisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

// Borrowed from https://stackoverflow.com/a/67133582/760435

public extension Publisher {
    /// Includes the current element as well as the previous element from the upstream publisher in a tuple where the
    /// previous element is optional.
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
    ///
    /// - Returns: A publisher of a tuple of the previous and current elements from the upstream publisher.
    func withPrevious() -> AnyPublisher<(previous: Output?, current: Output), Failure> {
        scan(Optional<(Output?, Output)>.none) { ($0?.1, $1) }
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }

    /// Includes the current element as well as the previous element from the upstream publisher in a tuple where the
    /// previous element is not optional.
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
    ///
    /// - Parameter initialPreviousValue: The initial value to use as the previous value when the upstream publisher
    ///   emits for the first time.
    /// - Returns: A publisher of a tuple of the previous and current elements from the upstream publisher.
    func withPrevious(_ initialPreviousValue: Output) -> AnyPublisher<(previous: Output, current: Output), Failure> {
        scan((initialPreviousValue, initialPreviousValue)) { ($0.1, $1) }.eraseToAnyPublisher()
    }
}

public extension NotificationCenter {
    /// Returns a publisher that emits events when broadcasting notifications.
    ///
    /// Unlike usual notification publishers this publisher does not retain the observed object, preventing reference
    /// cycles.
    ///
    /// - Parameters:
    ///   - name: The name of the notification to publish.
    ///   - object: The object posting the named notification. If `nil` the publisher emits elements for any object
    ///   producing a notification with the given name.
    /// - Returns: A publisher that emits events when broadcasting notifications.
    func weakPublisher<T: AnyObject>(for name: Notification.Name, object: T?) -> AnyPublisher<Notification, Never> {
        if let object {
            return publisher(for: name)
                .weakCapture(object)
                .filter { notification, object in
                    guard let notificationObject = notification.object as? AnyObject else {
                        return false
                    }
                    return notificationObject === object
                }
                .map(\.0)
                .eraseToAnyPublisher()
        }
        else {
            return publisher(for: name)
                .eraseToAnyPublisher()
        }
    }
}

public extension Publisher {
    /// Captures an object weakly and provides one of its properties as additional output.
    ///
    /// Does not emit when the object is `nil`.
    /// - Parameters:
    ///   - other: The object to weakly capture.
    ///   - keyPath: The key path for which to provide values.
    /// - Returns: A publisher combining the original output with values from the weakly captured object at the
    /// specified key path.
    func weakCapture<T: AnyObject, V>(_ other: T?, at keyPath: KeyPath<T, V>) -> AnyPublisher<(Output, V), Failure> {
        compactMap { [weak other] output -> (Output, V)? in
            guard let other else { return nil }
            return (output, other[keyPath: keyPath])
        }
        .eraseToAnyPublisher()
    }

    /// Captures an object weakly and provides it as additional output.
    ///
    /// Does not emit when the object is `nil`.
    /// - Parameters:
    ///   - other: The object to weakly capture.
    /// - Returns: A publisher combining the original output with the weakly captured object (if not `nil`).
    func weakCapture<T: AnyObject>(_ other: T?) -> AnyPublisher<(Output, T), Failure> {
        weakCapture(other, at: \T.self)
    }

    /// Safely receives elements from the upstream on the main thread.
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
