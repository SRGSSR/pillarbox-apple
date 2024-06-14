//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState: Equatable {
    static let empty = Self(event: nil, total: .zero, cache: .empty)

    private let event: AccessLogEvent?
    private let total: MetricsValues
    private let cache: Cache

    func updated(with log: AccessLog) -> Self? {
        let cache = cache.updated(with: log)
        if let openEvent = log.openEvent {
            return .init(event: openEvent, total: cache.total + .values(from: openEvent), cache: cache)
        }
        else if let lastClosedEvent = log.closedEvents.last {
            return .init(event: lastClosedEvent, total: cache.total, cache: cache)
        }
        else {
            return nil
        }
    }

    func updated(with log: AVPlayerItemAccessLog?) -> Self? {
        guard let log else { return nil }
        return updated(with: .init(log, after: cache.date))
    }

    func metrics(from state: Self) -> Metrics? {
        guard let event else { return nil }
        return .init(
            playbackStartDate: event.playbackStartDate,
            uri: event.uri,
            serverAddress: event.serverAddress,
            playbackSessionId: event.playbackSessionId,
            playbackStartOffset: event.playbackStartOffset,
            playbackType: event.playbackType,
            startupTime: event.startupTime,
            observedBitrateStandardDeviation: event.observedBitrateStandardDeviation,
            indicatedBitrate: event.indicatedBitrate,
            observedBitrate: event.observedBitrate,
            averageAudioBitrate: event.averageAudioBitrate,
            averageVideoBitrate: event.averageVideoBitrate,
            indicatedAverageBitrate: event.indicatedAverageBitrate,
            increment: total - state.total,
            total: total
        )
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
                    initial + .values(from: next)
                }
            )
        }
    }
}
