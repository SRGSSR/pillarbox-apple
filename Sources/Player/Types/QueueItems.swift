//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import OrderedCollections
import PillarboxCore

struct QueueItems: Equatable {
    let item: PlayerItem
    let playerItem: AVPlayerItem
}

extension QueueItems {
    private func metricEventsPublisher() -> AnyPublisher<[MetricEvent], Never> {
        Publishers.CombineLatest(
            item.metricLog.eventPublisher(),
            playerItem.metricLog.eventPublisher()
        )
        .map { $0 + $1 }
        .eraseToAnyPublisher()
    }

    func propertiesPublisher() -> AnyPublisher<QueueItemsProperties, Never> {
        Publishers.CombineLatest3(
            item.metadataPublisher,
            playerItem.propertiesPublisher,
            metricEventsPublisher()
        )
        .map { .init(metadata: $0, itemProperties: $1, metricEvents: $2) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}
