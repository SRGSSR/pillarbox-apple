//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

final actor PeriodicTimeSubscription<S, Failure>: Combine.Subscription where Failure: Error, S: Subscriber, S.Input == CMTime, S.Failure == Failure {
    private var subscriber: S?
    private let player: AVPlayer
    private let interval: CMTime
    private let queue: DispatchQueue

    private var demand: Subscribers.Demand = .none
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
        guard let subscriber = self.subscriber, demand > .none else { return }
        demand -= 1
        demand += subscriber.receive(time)
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
