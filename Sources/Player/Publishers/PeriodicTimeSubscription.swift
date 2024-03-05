//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

final class PeriodicTimeSubscription<S, Failure>: Subscription where Failure: Error, S: Subscriber, S.Input == CMTime, S.Failure == Failure {
    private var subscriber: S?
    private let player: AVPlayer
    private let interval: CMTime
    private let queue: DispatchQueue

    private let buffer = DemandBuffer<CMTime>()
    private var timeObserver: Any?

    init(subscriber: S, player: AVPlayer, interval: CMTime, queue: DispatchQueue) {
        self.subscriber = subscriber
        self.player = player
        self.interval = interval
        self.queue = queue
    }

    private func send(_ time: CMTime) {
        process(buffer.append(time))
    }

    func request(_ demand: Subscribers.Demand) {
        if timeObserver == nil {
            timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: queue) { [weak self] time in
                self?.send(time)
            }
        }
        process(buffer.request(demand))
    }

    func cancel() {
        if let timeObserver {
            player.removeTimeObserver(timeObserver)
            self.timeObserver = nil
        }
        subscriber = nil
    }

    private func process(_ values: [CMTime]) {
        guard let subscriber else { return }
        values.forEach { value in
            let demand = subscriber.receive(value)
            request(demand)
        }
    }
}
