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
public final class ReplaySubject<Output, Failure>: Subject where Failure: Error {
    private let buffer: LimitedBuffer<Output>

    private var subscriptions: [ReplaySubscription<Output, Failure>] = []
    private var completion: Subscribers.Completion<Failure>?

    private let lock = NSRecursiveLock()

    init(bufferSize: Int) {
        buffer = .init(size: bufferSize)
    }

    public func send(_ value: Output) {
        withLock(lock) {
            guard self.completion == nil else { return }
            buffer.append(value)
            subscriptions.forEach { subscription in
                subscription.send(value)
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
            buffer.values.forEach { value in
                subscription.send(value)
            }
            subscriber.receive(subscription: subscription)
            if let completion {
                subscription.send(completion: completion)
            }
            subscriptions.append(subscription)
        }
    }
}
