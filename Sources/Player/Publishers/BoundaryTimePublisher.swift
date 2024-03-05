//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

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

    func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, Void == S.Input {
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
