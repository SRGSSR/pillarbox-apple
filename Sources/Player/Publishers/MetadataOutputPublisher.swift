//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

struct MetadataOutputPublisher: Publisher {
    typealias Output = [AVTimedMetadataGroup]
    typealias Failure = Never

    private let item: AVPlayerItem
    private let identifiers: [String]
    private let queue: DispatchQueue

    init(item: AVPlayerItem, identifiers: [String], queue: DispatchQueue) {
        self.item = item
        self.identifiers = identifiers
        self.queue = queue
    }

    func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Output {
        let subscription = MetadataOutputSubscription(subscriber: subscriber, item: item, identifiers: identifiers, queue: queue)
        subscriber.receive(subscription: subscription)
    }
}
