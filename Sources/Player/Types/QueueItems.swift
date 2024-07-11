//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

struct QueueItems {
    let item: PlayerItem
    let playerItem: AVPlayerItem

    static func metricEventUpdate(from previous: Self?, to current: Self) -> MetricEventUpdate {
        if let previous, previous.item.id == current.item.id {
            let previousEvents = previous.events()
            let currentEvents = current.events()
            return .init(
                previousEvents: previousEvents,
                newEvents: currentEvents.subtracting(previousEvents)
            )
        }
        else {
            return .init(
                previousEvents: [],
                newEvents: current.events()
            )
        }
    }

    func events() -> [MetricEvent] {
        (item.metricLog.events + playerItem.metricLog.events).sorted { $0.date < $1.date }
    }

    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Publishers.Merge(
            item.metricLog.eventPublisher(),
            playerItem.metricLog.eventPublisher()
        )
        .eraseToAnyPublisher()
    }
}
