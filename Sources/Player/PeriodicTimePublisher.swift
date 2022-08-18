//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

extension Publishers {
    struct PeriodicTimePublisher: Publisher {
        typealias Output = CMTime
        typealias Failure = Never

        let player: AVPlayer
        let interval: CMTime
        let queue: DispatchQueue

        init(player: AVPlayer, interval: CMTime, queue: DispatchQueue = .main) {
            self.interval = interval
            self.queue = queue
            self.player = player
        }

        func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, CMTime == S.Input {
            let subscription = Subscription(subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }
}

private extension Publishers.PeriodicTimePublisher {
    final class Subscription<S: Subscriber>: Combine.Subscription where S.Input == Output, S.Failure == Failure {
        private var subscriber: S?

        init(subscriber: S) {
            self.subscriber = subscriber
        }

        func request(_ demand: Subscribers.Demand) {
        }

        func cancel() {
            subscriber = nil
        }
    }
}
