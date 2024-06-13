//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState: Equatable {
    static let empty = Self(cache: .empty, metrics: .empty)

    private let cache: MetricsCache
    let metrics: Metrics

    private func adding(event: AccessLogEvent, to cache: MetricsCache) -> Self {
        let total = cache.total.adding(.values(from: event))
        return .init(
            cache: cache,
            metrics: metrics.updated(with: event, total: total)
        )
    }

    private func returning(event: AccessLogEvent, in cache: MetricsCache) -> Self {
        return .init(
            cache: cache,
            metrics: metrics.updated(with: event, total: cache.total)
        )
    }

    func updated(with log: AccessLog) -> Self {
        let cache = cache.updated(with: log.closedEvents)
        if let openEvent = log.openEvent {
            return adding(event: openEvent, to: cache)
        }
        else if let lastClosedEvent = log.closedEvents.last {
            return returning(event: lastClosedEvent, in: cache)
        }
        else {
            return self
        }
    }

    func updated(with log: AVPlayerItemAccessLog) -> Self {
        updated(with: .init(log, after: cache.date))
    }
}
