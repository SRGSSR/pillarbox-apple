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
