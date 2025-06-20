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
        private let subscriber: RecursiveLock<S?>
        private let operation: () async throws(Failure) -> Output

        private let buffer = DemandBuffer<Output>()
        private let task: RecursiveLock<Task<Void, Never>?> = .init(initialState: nil)

        init(subscriber: S, operation: @escaping () async throws(Failure) -> Output) {
            self.subscriber = .init(initialState: subscriber)
            self.operation = operation
        }

        private func send(_ output: Output) {
            process(buffer.append(output))
        }

        private func performOperation() async {
            guard let subscriber = subscriber.locked() else { return }
            do {
                send(try await operation())
                subscriber.receive(completion: .finished)
            }
            catch {
                subscriber.receive(completion: .failure(error))
            }
        }

        func request(_ demand: Subscribers.Demand) {
            task.withLock { task in
                if task == nil {
                    task = Task {
                        await performOperation()
                    }
                }
            }
            process(buffer.request(demand))
        }

        func cancel() {
            task.withLock { task in
                task?.cancel()
                task = nil
            }
            subscriber.setLocked(nil)
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
