//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

#if compiler(>=6.0)
/// A publisher that delivers output from an `AsyncSequence`.
@available(iOS 18.0, tvOS 18.0, *)
public struct AsyncSequencePublisher<Output, Failure>: Publisher where Failure: Error {
    private let sequence: any AsyncSequence<Output, Failure>

    /// Creates a publisher from a given `AsyncSequence`.
    ///
    /// - Parameter sequence: The `AsyncSequence` to iterate on.
    public init<A>(from sequence: A) where A: AsyncSequence, A.Element == Output, A.Failure == Failure {
        self.sequence = sequence
    }

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
        let subscription = AsyncSequenceSubscription(subscriber: subscriber, sequence: sequence)
        subscriber.receive(subscription: subscription)
    }
}

@available(iOS 18.0, tvOS 18.0, *)
extension AsyncSequencePublisher {
    private final class AsyncSequenceSubscription<S>: Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
        private var subscriber: S?
        private let sequence: any AsyncSequence<Output, Failure>

        private let buffer = DemandBuffer<Output>()
        private var task: Task<Void, Error>?

        init(subscriber: S, sequence: any AsyncSequence<Output, Failure>) {
            self.subscriber = subscriber
            self.sequence = sequence
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
#endif
