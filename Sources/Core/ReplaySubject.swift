//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

/// A subject that stores a number of recent values into a buffer.
///
/// Upon subscription new subscribers automatically receive recent values available from the buffer, as well as
/// any relevant completion.
public final class ReplaySubject<Output, Failure>: Subject, @unchecked Sendable where Failure: Error {
    private let buffer: LimitedBuffer<Output>
    private var completion: Subscribers.Completion<Failure>?
    private let lock = NSRecursiveLock()
    var subscriptions: [ReplaySubscription<Output, Failure>] = []

    /// Creates a subject able to buffer the provided number of values.
    ///
    /// - Parameter bufferSize: The buffer size.
    public init(bufferSize: Int) {
        buffer = .init(size: bufferSize)
    }

    public func send(_ value: Output) {
        withLock(lock) {
            guard self.completion == nil else { return }
            buffer.append(value)
            subscriptions.forEach { subscription in
                subscription.append(value)
            }
            subscriptions.forEach { subscription in
                subscription.send()
            }
        }
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        withLock(lock) {
            guard self.completion == nil else { return }
            self.completion = completion
            subscriptions.forEach { subscription in
                subscription.send(completion: completion)
            }
        }
    }

    public func send(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        withLock(lock) {
            let subscription = ReplaySubscription(subscriber: subscriber, values: buffer.values)
            subscription.onCancel = { [weak self] in
                guard let self else { return }
                subscriptions.removeAll { $0 === subscription }
            }
            buffer.values.forEach { value in
                subscription.append(value)
                subscription.send()
            }
            subscriber.receive(subscription: subscription)
            if let completion {
                subscription.send(completion: completion)
            }
            subscriptions.append(subscription)
        }
    }
}
