//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

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

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, CMTime == S.Input {
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
