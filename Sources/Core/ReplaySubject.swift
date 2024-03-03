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
                subscription.receive(value)
            }
        }
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        withLock(lock) {
            guard self.completion == nil else { return }
            self.completion = completion
            subscriptions.forEach { subscription in
                subscription.receive(completion: completion)
            }
        }
    }

    public func send(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = ReplaySubscription(subscriber: subscriber)
        subscriber.receive(subscription: subscription)

        withLock(lock) {
            subscriptions.append(subscription)
            subscription.replay(buffer.values, completion: completion)
        }
    }
}
