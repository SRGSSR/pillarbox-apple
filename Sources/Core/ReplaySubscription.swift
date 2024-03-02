//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class ReplaySubscription<Output, Failure>: Subscription where Failure: Error {
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
