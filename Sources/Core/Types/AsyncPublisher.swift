//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

/// A publisher that delivers output from an asynchronous work unit.
public struct AsyncPublisher<Output, Failure>: Publisher where Failure: Error {
    private let operation: () async throws(Failure) -> Output

    /// Creates a publisher from a given asynchronous work unit.
    ///
    /// - Parameter operation: The work unit to perform.
    public init(operation: @escaping () async throws(Failure) -> Output) {
        self.operation = operation
    }

    // swiftlint:disable:next missing_docs
    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        let subscription = AsyncPublisherSubscription(subscriber: subscriber, operation: operation)
        subscriber.receive(subscription: subscription)
    }
}

extension AsyncPublisher {
    private final class AsyncPublisherSubscription<S>: Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
        private var subscriber: S?
        private let operation: () async throws(Failure) -> Output

        private let buffer = DemandBuffer<Output>()
        private var task: Task<Void, Never>?
        private let lock = NSRecursiveLock()

        init(subscriber: S, operation: @escaping () async throws(Failure) -> Output) {
            self.subscriber = subscriber
            self.operation = operation
        }

        private func send(_ output: Output) {
            lock.withLock {
                process(buffer.append(output))
            }
        }

        private func performOperation() async {
            guard let subscriber = lock.withLock({ subscriber }) else { return }
            do {
                send(try await operation())
                subscriber.receive(completion: .finished)
            }
            catch {
                subscriber.receive(completion: .failure(error))
            }
        }

        func request(_ demand: Subscribers.Demand) {
            lock.withLock {
                if task == nil {
                    task = Task {
                        await performOperation()
                    }
                }
                process(buffer.request(demand))
            }
        }

        func cancel() {
            lock.withLock {
                task?.cancel()
                task = nil
                subscriber = nil
            }
        }

        private func process(_ values: [Output]) {
            guard let subscriber = lock.withLock({ subscriber }) else { return }
            values.forEach { value in
                let demand = subscriber.receive(value)
                request(demand)
            }
        }
    }
}
