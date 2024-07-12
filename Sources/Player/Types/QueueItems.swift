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

    static func metricEventUpdate(from previous: Self?, to current: Self) -> MetricEventUpdate {
        if let previous, previous.item == current.item {
            return update(from: previous.events(), to: current.events())
        }
        else {
            return .init(previousEvents: [], newEvents: current.events())
        }
    }

    private static func update(from previousEvents: [MetricEvent], to currentEvents: [MetricEvent]) -> MetricEventUpdate {
        let previousEventsSet = OrderedSet(previousEvents)
        let currentEventsSet = OrderedSet(currentEvents)
        let previousCommonEventsSet = previousEventsSet.intersection(currentEventsSet)
        return .init(
            previousEvents: Array(previousCommonEventsSet),
            newEvents: Array(currentEventsSet.subtracting(previousCommonEventsSet))
        )
    }

    private func events() -> [MetricEvent] {
        item.metricLog.events + playerItem.metricLog.events
    }

    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Publishers.Merge(
            item.metricLog.eventPublisher(),
            playerItem.metricLog.eventPublisher()
        )
        .eraseToAnyPublisher()
    }
}
