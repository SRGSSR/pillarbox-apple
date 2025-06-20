//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

private struct _BoundaryTimePublisher: Publisher {
    typealias Output = Void
    typealias Failure = Never

    private let player: AVPlayer
    private let times: [CMTime]
    private let queue: DispatchQueue

    init(player: AVPlayer, times: [CMTime], queue: DispatchQueue) {
        self.player = player
        self.times = times
        self.queue = queue
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
        let subscription = BoundaryTimeSubscription(subscriber: subscriber, player: player, times: times, queue: queue)
        subscriber.receive(subscription: subscription)
    }
}

extension Publishers {
    static func BoundaryTimePublisher(for player: AVPlayer, times: [CMTime], queue: DispatchQueue = .main) -> AnyPublisher<Void, Never> {
        _BoundaryTimePublisher(player: player, times: times, queue: queue)
            .eraseToAnyPublisher()
    }
}

private extension _BoundaryTimePublisher {
    final class BoundaryTimeSubscription<S>: Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
        private let subscriber: RecursiveLock<S?>
        private let player: AVPlayer
        private let times: [NSValue]
        private let queue: DispatchQueue

        private let buffer = DemandBuffer<Void>()
        private let timeObserver: RecursiveLock<Any?> = .init(initialState: nil)

        init(subscriber: S, player: AVPlayer, times: [CMTime], queue: DispatchQueue) {
            self.subscriber = .init(initialState: subscriber)
            self.player = player
            self.times = times.map { NSValue(time: $0) }
            self.queue = queue
        }

        func request(_ demand: Subscribers.Demand) {
            timeObserver.withLock { timeObserver in
                if timeObserver == nil {
                    timeObserver = player.addBoundaryTimeObserver(forTimes: times, queue: queue) { [weak self] in
                        self?.send()
                    }
                }
            }
            process(buffer.request(demand))
        }

        private func send() {
            process(buffer.append(()))
        }

        func cancel() {
            timeObserver.withLock { timeObserver in
                if let timeObserver {
                    player.removeTimeObserver(timeObserver)
                }
                timeObserver = nil
            }
            subscriber.withLock { subscriber in
                subscriber = nil
            }
        }

        private func process(_ values: [Void]) {
            guard let subscriber = subscriber.locked() else { return }
            values.forEach { value in
                let demand = subscriber.receive(value)
                request(demand)
            }
        }
    }
}
