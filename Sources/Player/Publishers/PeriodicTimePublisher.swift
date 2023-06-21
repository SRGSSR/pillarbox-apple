//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core

extension Publishers {
    fileprivate struct _PeriodicTimePublisher: Publisher {
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

        func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, CMTime == S.Input {
            let subscription = Subscription(subscriber: subscriber, player: player, interval: interval, queue: queue)
            subscriber.receive(subscription: subscription)
        }
    }

    static func PeriodicTimePublisher(for player: AVPlayer, interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest(
            Publishers._PeriodicTimePublisher(player: player, interval: interval, queue: queue),
            player.currentItemTimeRangePublisher()
        )
        .compactMap { time, timeRange in
            let clampedTime = time.clamped(to: timeRange)
            return clampedTime.isValid ? clampedTime : nil
        }
        .removeDuplicates(by: CMTime.close(within: interval.seconds / 2))
        .eraseToAnyPublisher()
    }
}

private extension Publishers._PeriodicTimePublisher {
    final actor Subscription<S>: Combine.Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
        private var subscriber: S?
        private let player: AVPlayer
        private let interval: CMTime
        private let queue: DispatchQueue

        private var demand = Subscribers.Demand.none
        private var timeObserver: Any?

        init(subscriber: S, player: AVPlayer, interval: CMTime, queue: DispatchQueue) {
            self.subscriber = subscriber
            self.player = player
            self.interval = interval
            self.queue = queue
        }

        private func processDemand(_ demand: Subscribers.Demand) {
            self.demand += demand
            guard timeObserver == nil else { return }
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: queue) { [weak self] time in
                self?.processTime(time)
            }
        }

        private func processCancellation() {
            if let timeObserver {
                player.removeTimeObserver(timeObserver)
                self.timeObserver = nil
            }
            subscriber = nil
        }

        private func send(_ time: CMTime) {
            guard let subscriber = self.subscriber, self.demand > .none else { return }
            self.demand -= 1
            self.demand += subscriber.receive(time)
        }

        private nonisolated func processTime(_ time: CMTime) {
            Task {
                await send(time)
            }
        }

        nonisolated func request(_ demand: Subscribers.Demand) {
            Task {
                await processDemand(demand)
            }
        }

        nonisolated func cancel() {
            Task {
                await processCancellation()
            }
        }
    }
}
