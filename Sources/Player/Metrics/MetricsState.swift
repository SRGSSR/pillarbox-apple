//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState: Equatable {
    static let empty = Self(date: nil, total: .zero, metrics: .empty)

    private let date: Date?
    private let total: MetricsValues

    let metrics: Metrics

    func updated(with log: AccessLog) -> Self {
        let total = log.closedEvents.reduce(total) { initial, next in
            initial.adding(.values(from: next))
        }

        if let openEvent = log.openEvent {
            let openTotal = total.adding(.values(from: openEvent))
            return .init(
                date: log.closedEvents.last?.playbackStartDate ?? date,
                total: total,
                metrics: .init(
                    uri: openEvent.uri,
                    serverAddress: openEvent.serverAddress,
                    playbackSessionId: openEvent.playbackSessionId,
                    playbackStartDate: openEvent.playbackStartDate,
                    playbackStartOffset: openEvent.playbackStartOffset,
                    playbackType: openEvent.playbackType,
                    startupTime: openEvent.startupTime,
                    observedBitrateStandardDeviation: openEvent.observedBitrateStandardDeviation,
                    indicatedBitrate: openEvent.indicatedBitrate,
                    observedBitrate: openEvent.observedBitrate,
                    averageAudioBitrate: openEvent.averageAudioBitrate,
                    averageVideoBitrate: openEvent.averageVideoBitrate,
                    indicatedAverageBitrate: openEvent.indicatedAverageBitrate,
                    increment: openTotal.subtracting(metrics.total),
                    total: openTotal
                )
            )
        }
        else if let lastClosedEvent = log.closedEvents.last {
            return .init(
                date: lastClosedEvent.playbackStartDate,
                total: total,
                metrics: .init(
                    uri: lastClosedEvent.uri,
                    serverAddress: lastClosedEvent.serverAddress,
                    playbackSessionId: lastClosedEvent.playbackSessionId,
                    playbackStartDate: lastClosedEvent.playbackStartDate,
                    playbackStartOffset: lastClosedEvent.playbackStartOffset,
                    playbackType: lastClosedEvent.playbackType,
                    startupTime: lastClosedEvent.startupTime,
                    observedBitrateStandardDeviation: lastClosedEvent.observedBitrateStandardDeviation,
                    indicatedBitrate: lastClosedEvent.indicatedBitrate,
                    observedBitrate: lastClosedEvent.observedBitrate,
                    averageAudioBitrate: lastClosedEvent.averageAudioBitrate,
                    averageVideoBitrate: lastClosedEvent.averageVideoBitrate,
                    indicatedAverageBitrate: lastClosedEvent.indicatedAverageBitrate,
                    increment: total.subtracting(metrics.total),
                    total: total
                )
            )
        }
        else {
            return self
        }
    }

    func updated(with log: AVPlayerItemAccessLog) -> Self {
        updated(with: .init(log, after: date))
    }
}
