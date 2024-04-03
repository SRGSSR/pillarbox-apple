//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

final class MetadataOutputSubscription<S>: NSObject, Subscription, AVPlayerItemMetadataOutputPushDelegate
where S: Subscriber, S.Input == [AVTimedMetadataGroup], S.Failure == Never {
    private var subscriber: S?
    private let item: AVPlayerItem
    private let identifiers: [String]
    private let queue: DispatchQueue
    private let buffer = DemandBuffer<[AVTimedMetadataGroup]>()
    private var output: AVPlayerItemOutput?

    init(subscriber: S, item: AVPlayerItem, identifiers: [String], queue: DispatchQueue) {
        self.subscriber = subscriber
        self.item = item
        self.identifiers = identifiers
        self.queue = queue
    }

    func request(_ demand: Subscribers.Demand) {
        if output == nil {
            let output = AVPlayerItemMetadataOutput(identifiers: !identifiers.isEmpty ? identifiers : nil)
            output.setDelegate(self, queue: queue)
            item.add(output)
            self.output = output
        }
        process(buffer.request(demand))
    }

    func cancel() {
        if let output {
            item.remove(output)
            self.output = nil
        }
        subscriber = nil
    }

    private func process(_ values: [[AVTimedMetadataGroup]]) {
        guard let subscriber else { return }
        values.forEach { value in
            let demand = subscriber.receive(value)
            request(demand)
        }
    }

    func metadataOutput(_ output: AVPlayerItemMetadataOutput, didOutputTimedMetadataGroups groups: [AVTimedMetadataGroup], from track: AVPlayerItemTrack?) {
        process(buffer.append(groups))
    }
}
