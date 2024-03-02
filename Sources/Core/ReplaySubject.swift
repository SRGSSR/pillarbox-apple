//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

private final class ReplaySubscription<Output, Failure>: Subscription where Failure: Error {
    private var subscriber: AnySubscriber<Output, Failure>?
    private var demand: Subscribers.Demand = .none
    private let lock = NSRecursiveLock()

    init<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
        self.subscriber = AnySubscriber(subscriber)
    }

    func request(_ demand: Subscribers.Demand) {
        withLock(lock) {
            self.demand += demand
        }
    }

    func receive(_ value: Output) {
        withLock(lock) {
            guard let subscriber = self.subscriber, demand > .none else { return }
            demand -= 1
            demand += subscriber.receive(value)
        }
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        withLock(lock) {
            subscriber?.receive(completion: completion)
        }
    }

    func cancel() {
        withLock(lock) {
            subscriber = nil
        }
    }
}

public final class ReplaySubject<Output, Failure>: Subject where Failure: Error {
    private let buffer: Buffer<Output>

    private var subscriptions: [ReplaySubscription<Output, Failure>] = []
    private var completion: Subscribers.Completion<Failure>?
    private let lock = NSRecursiveLock()

    init(bufferSize: Int) {
        buffer = .init(size: bufferSize)
    }

    public func send(_ value: Output) {
        withLock(lock) {
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

            buffer.values.forEach { value in
                subscription.receive(value)
            }
            if let completion {
                subscription.receive(completion: completion)
            }
        }
    }
}
