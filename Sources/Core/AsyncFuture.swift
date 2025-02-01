//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

/// A publisher that delivers output from an `AsyncSequence`.
public struct AsyncFuture<Output, Failure>: Publisher where Failure: Error {
    private let operation: () async throws -> Output

    public init(operation: @escaping () async throws -> Output) {
        self.operation = operation
    }

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        let subscription = AsyncFutureSubscription(subscriber: subscriber, operation: operation)
        subscriber.receive(subscription: subscription)
    }
}

extension AsyncFuture {
    private final class AsyncFutureSubscription<S>: Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
        private var subscriber: S?
        private let operation: () async throws -> Output

        private let buffer = DemandBuffer<Output>()
        private var task: Task<Void, Never>?

        init(subscriber: S, operation: @escaping () async throws -> Output) {
            self.subscriber = subscriber
            self.operation = operation
        }

        private func send(_ output: Output) {
            process(buffer.append(output))
        }

        private func iterate() async {
            do {
                for try await output in sequence {
                    send(output)
                }
                subscriber?.receive(completion: .finished)
            }
            catch {
                subscriber?.receive(completion: .failure(error))
            }
        }

        func request(_ demand: Subscribers.Demand) {
            if task == nil {
                task = Task {
                    await iterate()
                }
            }
            process(buffer.request(demand))
        }

        func cancel() {
            task?.cancel()
            task = nil
            subscriber = nil
        }

        private func process(_ values: [Output]) {
            guard let subscriber else { return }
            values.forEach { value in
                let demand = subscriber.receive(value)
                request(demand)
            }
        }
    }
}
