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

    private func events() -> [MetricEvent] {
        item.metricLog.events + playerItem.metricLog.events
    }

    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Publishers.Merge(
            item.metricLog.eventPublisher(),
            playerItem.metricLog.eventPublisher()
        )
        .prepend(events().publisher)
        .eraseToAnyPublisher()
    }
}
