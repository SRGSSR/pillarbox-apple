//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState: Equatable {
    private static let nonCacheableEventCount = 2

    static let empty = Self(time: .invalid, event: nil, cache: .empty, total: .zero)

    private let time: CMTime
    private let event: AccessLogEvent?
    private let cache: MetricsCache
    private let total: MetricsValues

    func adding(events: [AccessLogEvent], at time: CMTime) -> Self {
        let updatedCache = cache.adding(events: events.dropLast(Self.nonCacheableEventCount))
        let updatedTotal = events
            .prefix(Self.nonCacheableEventCount)
            .reduce(updatedCache.total) { $0 + .values(from: $1) }
        return .init(time: time, event: events.last, cache: updatedCache, total: updatedTotal)
    }

    func updated(for item: AVPlayerItem) -> Self? {
        guard let events = item.accessLog()?.events, !events.isEmpty else { return nil }
        return adding(
            events: events
                .suffix(max(events.count - cache.count, 0))
                .map { AccessLogEvent($0) },
            at: item.currentTime()
        )
    }

    func metrics(from state: Self) -> Metrics {
        .init(
            time: time,
            uri: event?.uri,
            serverAddress: event?.serverAddress,
            playbackStartDate: event?.playbackStartDate,
            playbackSessionId: event?.playbackSessionId,
            playbackStartOffset: event?.playbackStartOffset,
            playbackType: event?.playbackType,
            startupTime: event?.startupTime,
            observedBitrateStandardDeviation: event?.observedBitrateStandardDeviation,
            indicatedBitrate: event?.indicatedBitrate,
            observedBitrate: event?.observedBitrate,
            averageAudioBitrate: event?.averageAudioBitrate,
            averageVideoBitrate: event?.averageVideoBitrate,
            indicatedAverageBitrate: event?.indicatedAverageBitrate,
            increment: total - state.total,
            total: total
        )
    }
}
