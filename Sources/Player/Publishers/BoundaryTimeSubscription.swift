//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

final class BoundaryTimeSubscription<S>: Subscription where S: Subscriber, S.Input == Void, S.Failure == Never {
    private var subscriber: S?
    private let player: AVPlayer
    private let times: [CMTime]
    private let queue: DispatchQueue

    private let buffer = DemandBuffer<Void>()
    private var timeObserver: Any?

    init(subscriber: S, player: AVPlayer, times: [CMTime], queue: DispatchQueue) {
        self.subscriber = subscriber
        self.player = player
        self.times = times
        self.queue = queue
    }

    private func send() {
        process(buffer.append(()))
    }

    func request(_ demand: Subscribers.Demand) {
        if timeObserver == nil {
            let timeValues = times.map { NSValue(time: $0) }
            timeObserver = player.addBoundaryTimeObserver(forTimes: timeValues, queue: queue) { [weak self] in
                self?.send()
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

    private func process(_ values: [Void]) {
        guard let subscriber else { return }
        values.forEach { value in
            let demand = subscriber.receive(value)
            request(demand)
        }
    }
}
