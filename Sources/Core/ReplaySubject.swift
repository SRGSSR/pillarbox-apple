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
    private var completion: Subscribers.Completion<Failure>?
    private let lock = NSRecursiveLock()
    var subscriptions: [ReplaySubscription] = []

    /// Creates a subject able to buffer the provided number of values.
    ///
    /// - Parameter bufferSize: The buffer size.
    public init(bufferSize: Int) {
        buffer = .init(size: bufferSize)
    }

    // swiftlint:disable:next missing_docs
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

    // swiftlint:disable:next missing_docs
    public func send(completion: Subscribers.Completion<Failure>) {
        withLock(lock) {
            guard self.completion == nil else { return }
            self.completion = completion
            subscriptions.forEach { subscription in
                subscription.send(completion: completion)
            }
        }
    }

    // swiftlint:disable:next missing_docs
    public func send(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    // swiftlint:disable:next missing_docs
    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
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

extension ReplaySubject {
    final class ReplaySubscription: Subscription {
        var onCancel: (() -> Void)?

        private var subscriber: AnySubscriber<Output, Failure>?
        private var buffer = DemandBuffer<Output>()
        private var pendingValues: [Output] = []

        init<S>(subscriber: S, values: [Output]) where S: Subscriber, S.Input == Output, S.Failure == Failure {
            self.subscriber = AnySubscriber(subscriber)
        }

        func request(_ demand: Subscribers.Demand) {
            process(buffer.request(demand))
        }

        func append(_ value: Output) {
            pendingValues += buffer.append(value)
        }

        func send() {
            let values = pendingValues
            pendingValues = []
            process(values)
        }

        func send(completion: Subscribers.Completion<Failure>) {
            process(completion: completion)
        }

        func cancel() {
            subscriber = nil
            onCancel?()
            onCancel = nil
        }

        private func process(_ values: [Output]) {
            guard let subscriber else { return }
            values.forEach { value in
                let demand = subscriber.receive(value)
                request(demand)
            }
        }

        private func process(completion: Subscribers.Completion<Failure>?) {
            guard let subscriber, let completion else { return }
            subscriber.receive(completion: completion)
        }
    }
}
