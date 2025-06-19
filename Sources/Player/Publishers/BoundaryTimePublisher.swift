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

extension _BoundaryTimePublisher {
    private final class BoundaryTimeSubscription<S>: Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
        private var subscriber: S?
        private let player: AVPlayer
        private let times: [CMTime]
        private let queue: DispatchQueue

        private let buffer = DemandBuffer<Void>()
        private var timeObserver: Any?
        private let lock = NSRecursiveLock()

        init(subscriber: S, player: AVPlayer, times: [CMTime], queue: DispatchQueue) {
            self.subscriber = subscriber
            self.player = player
            self.times = times
            self.queue = queue
        }

        func request(_ demand: Subscribers.Demand) {
            lock.withLock {
                if timeObserver == nil {
                    let timeValues = times.map { NSValue(time: $0) }
                    timeObserver = player.addBoundaryTimeObserver(forTimes: timeValues, queue: queue) { [weak self] in
                        self?.send()
                    }
                }
                process(buffer.request(demand))
            }
        }

        private func send() {
            lock.withLock {
                process(buffer.append(()))
            }
        }

        func cancel() {
            lock.withLock {
                if let timeObserver {
                    player.removeTimeObserver(timeObserver)
                    self.timeObserver = nil
                }
                subscriber = nil
            }
        }

        private func process(_ values: [Void]) {
            guard let subscriber = lock.withLock({ subscriber }) else { return }
            values.forEach { value in
                let demand = subscriber.receive(value)
                request(demand)
            }
        }
    }
}
