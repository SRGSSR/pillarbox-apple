//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState: Equatable {
    static let empty = Self(cache: .empty, metrics: .empty)

    private let cache: Cache
    let metrics: Metrics

    func updated(with log: AccessLog) -> Self {
        let cache = cache.updated(with: log.closedEvents)
        if let openEvent = log.openEvent {
            let total = cache.total.adding(.values(from: openEvent))
            return .init(
                cache: cache,
                metrics: metrics.updated(with: openEvent, total: total)
            )
        }
        else if let lastClosedEvent = log.closedEvents.last {
            return .init(
                cache: cache,
                metrics: metrics.updated(with: lastClosedEvent, total: cache.total)
            )
        }
        else {
            return self
        }
    }

    func updated(with log: AVPlayerItemAccessLog) -> Self {
        updated(with: .init(log, after: cache.date))
    }
}

private extension MetricsState {
    struct Cache: Equatable {
        static let empty = Self(date: nil, total: .zero)

        let date: Date?
        let total: MetricsValues

        func updated(with events: [AccessLogEvent]) -> Self {
            guard let lastEvent = events.last else { return self }
            return .init(
                date: lastEvent.playbackStartDate,
                total: events.reduce(total) { initial, next in
                    initial.adding(.values(from: next))
                }
            )
        }
    }
}
