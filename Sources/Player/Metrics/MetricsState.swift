//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState: Equatable {
    static let empty = Self(metrics: .empty, cache: .empty)

    let metrics: Metrics
    private let cache: Cache

    func updated(with log: AccessLog) -> Self {
        updatedWithOpenEvent(from: log) ?? updatedWithClosedEvents(from: log) ?? .empty
    }

    private func updatedWithOpenEvent(from log: AccessLog) -> Self? {
        guard let openEvent = log.openEvent else { return nil }
        let updatedCache = cache.updated(with: log)
        return .init(
            metrics: metrics.updated(
                with: openEvent,
                total: updatedCache.total.adding(.values(from: openEvent))
            ),
            cache: updatedCache
        )
    }

    private func updatedWithClosedEvents(from log: AccessLog) -> Self? {
        guard let lastClosedEvent = log.closedEvents.last else { return nil }
        let updatedCache = cache.updated(with: log)
        return .init(
            metrics: metrics.updated(with: lastClosedEvent, total: updatedCache.total),
            cache: updatedCache
        )
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

        func updated(with log: AccessLog) -> Self {
            guard let lastEvent = log.closedEvents.last else { return self }
            return .init(
                date: lastEvent.playbackStartDate,
                total: log.closedEvents.reduce(total) { initial, next in
                    initial.adding(.values(from: next))
                }
            )
        }
    }
}
