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

    private func updatedMetrics(with event: AccessLogEvent, total: MetricsValues) -> Metrics {
        .init(
            uri: event.uri,
            serverAddress: event.serverAddress,
            playbackSessionId: event.playbackSessionId,
            playbackStartDate: event.playbackStartDate,
            playbackStartOffset: event.playbackStartOffset,
            playbackType: event.playbackType,
            startupTime: event.startupTime,
            observedBitrateStandardDeviation: event.observedBitrateStandardDeviation,
            indicatedBitrate: event.indicatedBitrate,
            observedBitrate: event.observedBitrate,
            averageAudioBitrate: event.averageAudioBitrate,
            averageVideoBitrate: event.averageVideoBitrate,
            indicatedAverageBitrate: event.indicatedAverageBitrate,
            increment: total.subtracting(metrics.total),
            total: total
        )
    }

    func updated(with log: AccessLog) -> Self {
        let cache = cache.updated(with: log.closedEvents)

        if let openEvent = log.openEvent {
            let total = cache.total.adding(.values(from: openEvent))
            return .init(
                cache: cache,
                metrics: updatedMetrics(with: openEvent, total: total)
            )
        }
        else if let lastClosedEvent = log.closedEvents.last {
            return .init(
                cache: cache,
                metrics: updatedMetrics(with: lastClosedEvent, total: cache.total)
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
