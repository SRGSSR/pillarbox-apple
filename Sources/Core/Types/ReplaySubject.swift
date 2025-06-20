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

    private let subscriptions: RecursiveLock<[ReplaySubscription]> = .init(initialState: [])
    private let completion: RecursiveLock<Subscribers.Completion<Failure>?> = .init(initialState: nil)

    /// For use in tests only
    var isEmpty: Bool {
        subscriptions.withLock(\.isEmpty)
    }

    /// Creates a subject able to buffer the provided number of values.
    ///
    /// - Parameter bufferSize: The buffer size.
    public init(bufferSize: Int) {
        buffer = .init(size: bufferSize)
    }

    // swiftlint:disable:next missing_docs
    public func send(_ value: Output) {
        guard completion.locked() == nil else { return }
        buffer.append(value)

        let subscriptions = subscriptions.locked()
        subscriptions.forEach { subscription in
            subscription.append(value)
        }
        subscriptions.forEach { subscription in
            subscription.send()
        }
    }

    // swiftlint:disable:next missing_docs
    public func send(completion: Subscribers.Completion<Failure>) {
        self.completion.withLock { _completion in
            guard _completion == nil else { return }
            _completion = completion
        }

        let subscriptions = subscriptions.locked()
        subscriptions.forEach { subscription in
            subscription.send(completion: completion)
        }
    }

    // swiftlint:disable:next missing_docs
    public func send(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    // swiftlint:disable:next missing_docs
    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
        let subscription = ReplaySubscription(subscriber: subscriber) { [weak self] subscription in
            self?.removeSubscription(subscription)
        }
        buffer.values.forEach { value in
            subscription.append(value)
            subscription.send()
        }
        subscriber.receive(subscription: subscription)
        if let completion = completion.locked() {
            subscription.send(completion: completion)
        }
        subscriptions.withLock { subscriptions in
            subscriptions.append(subscription)
        }
    }

    private func removeSubscription(_ subscription: ReplaySubscription) {
        subscriptions.withLock { subscriptions in
            subscriptions.removeAll { $0 === subscription }
        }
    }
}

extension ReplaySubject {
    final class ReplaySubscription: Subscription {
        private let subscriber: RecursiveLock<AnySubscriber<Output, Failure>?>
        private let onCancel: RecursiveLock<((ReplaySubscription) -> Void)?>

        private let buffer = DemandBuffer<Output>()
        private let pendingValues: RecursiveLock<[Output]> = .init(initialState: [])

        init<S>(subscriber: S, onCancel: @escaping (ReplaySubscription) -> Void) where S: Subscriber, S.Input == Output, S.Failure == Failure {
            self.subscriber = .init(initialState: AnySubscriber(subscriber))
            self.onCancel = .init(initialState: onCancel)
        }

        func request(_ demand: Subscribers.Demand) {
            process(buffer.request(demand))
        }

        func append(_ value: Output) {
            pendingValues.withLock { pendingValues in
                pendingValues += buffer.append(value)
            }
        }

        func send() {
            let values = pendingValues.withLock { pendingValues in
                let values = pendingValues
                pendingValues = []
                return values
            }
            process(values)
        }

        func send(completion: Subscribers.Completion<Failure>) {
            guard let subscriber = subscriber.locked() else { return }
            subscriber.receive(completion: completion)
        }

        func cancel() {
            subscriber.setLocked(nil)
            onCancel.withLock { [weak self] onCancel in
                if let self {
                    onCancel?(self)
                }
                onCancel = nil
            }
        }

        private func process(_ values: [Output]) {
            guard let subscriber = subscriber.locked() else { return }
            values.forEach { value in
                let demand = subscriber.receive(value)
                request(demand)
            }
        }
    }
}
