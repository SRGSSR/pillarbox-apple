//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

public extension Publishers {
    /// Accumulate the results of a list of publishers and deliver them as a stream of arrays containing the latest
    /// values in publisher order. The first array is emitted once all publishers have at least emitted a value once.
    /// - Parameter publishers: The publishers to accumulate
    /// - Returns: The publisher
    static func AccumulateLatestMany<Upstream>(
        _ publishers: Upstream...
    ) -> AnyPublisher<[Upstream.Output], Upstream.Failure> where Upstream: Publisher {
        AccumulateLatestMany(publishers)
    }

    /// Accumulate the results of a list of publishers and deliver them as a stream of arrays containing the latest
    /// values in publisher order. The first array is emitted once all publishers have at least emitted a value once.
    /// - Parameter publishers: The publishers to accumulate
    /// - Returns: The publisher
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
                .map { t1, t2 in
                    [t1, t2]
                }
                .eraseToAnyPublisher()
        case 3:
            return Publishers.CombineLatest3(publishersArray[0], publishersArray[1], publishersArray[2])
                .map { t1, t2, t3 in
                    [t1, t2, t3]
                }
                .eraseToAnyPublisher()
        default:
            let half = publishersArray.count / 2
            return Publishers.CombineLatest(
                AccumulateLatestMany(Array(publishersArray[0..<half])),
                AccumulateLatestMany(Array(publishersArray[half..<publishersArray.count]))
            )
            .map { array1, array2 in
                array1 + array2
            }
            .eraseToAnyPublisher()
        }
    }
}

public extension NotificationCenter {
    /// The usual notification publisher retains the filter object, potentially creating cycles. The following
    /// publisher avoids this issue while still only observing the filter object (if any), even after it is
    /// eventually deallocated.
    /// - Parameters:
    ///   - name: The notification to observe.
    ///   - object: The object to observe (weakly captured).
    /// - Returns: A notification publisher.
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
    /// Capture another object weakly and provide one of its properties as additional output. Does not emit when the
    /// object is `nil`.
    /// - Parameters:
    ///   - other: The other object to weakly capture.
    ///   - keyPath: The key path for which to provide values.
    /// - Returns: A publisher combining the original output with properties from the weakly captured object.
    func weakCapture<T: AnyObject, V>(_ other: T?, at keyPath: KeyPath<T, V>) -> AnyPublisher<(Output, V), Failure> {
        compactMap { [weak other] output -> (Output, V)? in
            guard let other else { return nil }
            return (output, other[keyPath: keyPath])
        }
        .eraseToAnyPublisher()
    }

    /// Capture another object weakly and provide it as additional output. Does not emit when the object is `nil`.
    /// - Parameters:
    ///   - other: The other object to weakly capture.
    /// - Returns: A publisher combining the original output with the weakly captured object (if not `nil`).
    func weakCapture<T: AnyObject>(_ other: T?) -> AnyPublisher<(Output, T), Failure> {
        weakCapture(other, at: \T.self)
    }

    /// Safely receive elements from the publisher on the main thread.
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
