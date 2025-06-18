//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

private struct _PeriodicTimePublisher: Publisher {
    typealias Output = CMTime
    typealias Failure = Never

    private let player: AVPlayer
    private let interval: CMTime
    private let queue: DispatchQueue

    init(player: AVPlayer, interval: CMTime, queue: DispatchQueue) {
        self.player = player
        self.interval = interval
        self.queue = queue
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
        let subscription = PeriodicTimeSubscription(subscriber: subscriber, player: player, interval: interval, queue: queue)
        subscriber.receive(subscription: subscription)
    }
}

extension Publishers {
    static func PeriodicTimePublisher(for player: AVPlayer, interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        _PeriodicTimePublisher(player: player, interval: interval, queue: queue)
            .removeDuplicates(by: CMTime.close(within: interval.seconds / 2))
            .eraseToAnyPublisher()
    }
}

extension _PeriodicTimePublisher {
    private final class PeriodicTimeSubscription<S>: Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
        private var subscriber: S?
        private let player: AVPlayer
        private let interval: CMTime
        private let queue: DispatchQueue

        private let buffer = DemandBuffer<CMTime>()
        private var timeObserver: Any?
        private let lock = NSRecursiveLock()

        init(subscriber: S, player: AVPlayer, interval: CMTime, queue: DispatchQueue) {
            self.subscriber = subscriber
            self.player = player
            self.interval = interval
            self.queue = queue
        }

        func request(_ demand: Subscribers.Demand) {
            withLock(lock) {
                if timeObserver == nil {
                    timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: queue) { [weak self] time in
                        self?.send(time)
                    }
                }
                process(buffer.request(demand))
            }
        }

        private func send(_ time: CMTime) {
            withLock(lock) {
                process(buffer.append(time))
            }
        }

        func cancel() {
            withLock(lock) {
                if let timeObserver {
                    player.removeTimeObserver(timeObserver)
                    self.timeObserver = nil
                }
                subscriber = nil
            }
        }

        private func process(_ values: [CMTime]) {
            guard let subscriber = withLock(lock, execute: { subscriber }) else { return }
            values.forEach { value in
                let demand = subscriber.receive(value)
                request(demand)
            }
        }
    }
}
