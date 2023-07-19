//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension Publishers {
    fileprivate struct _BoundaryTimePublisher: Publisher {
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

        func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Void == S.Input {
            let subscription = Subscription(subscriber: subscriber, player: player, times: times, queue: queue)
            subscriber.receive(subscription: subscription)
        }
    }

    static func BoundaryTimePublisher(for player: AVPlayer, times: [CMTime], queue: DispatchQueue = .main) -> AnyPublisher<Void, Never> {
        Publishers._BoundaryTimePublisher(player: player, times: times, queue: queue)
            .eraseToAnyPublisher()
    }
}

private extension Publishers._BoundaryTimePublisher {
    final actor Subscription<S>: Combine.Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
        private var subscriber: S?
        private let player: AVPlayer
        private let times: [CMTime]
        private let queue: DispatchQueue

        private var demand = Subscribers.Demand.none
        private var timeObserver: Any?

        init(subscriber: S, player: AVPlayer, times: [CMTime], queue: DispatchQueue) {
            self.subscriber = subscriber
            self.player = player
            self.times = times
            self.queue = queue
        }

        private func processDemand(_ demand: Subscribers.Demand) {
            self.demand += demand
            guard timeObserver == nil else { return }
            let timeValues = times.map { NSValue(time: $0) }
            timeObserver = player.addBoundaryTimeObserver(forTimes: timeValues, queue: queue) { [weak self] in
                self?.processTime()
            }
        }

        private func processCancellation() {
            if let timeObserver {
                player.removeTimeObserver(timeObserver)
                self.timeObserver = nil
            }
            subscriber = nil
        }

        private func send() {
            guard let subscriber = self.subscriber, self.demand > .none else { return }
            self.demand -= 1
            self.demand += subscriber.receive(())
        }

        private nonisolated func processTime() {
            Task {
                await send()
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
