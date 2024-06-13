//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState: Equatable {
    static let empty = Self(closedDate: nil, closedTotal: .zero, metrics: .empty)

    private let closedDate: Date?
    private let closedTotal: MetricsValues

    let metrics: Metrics

    func updated(with log: AccessLog) -> Self {
        let closedTotal = log.closedEvents.reduce(closedTotal) { initial, next in
            initial.adding(.values(from: next))
        }

        if let openEvent = log.openEvent {
            let total = closedTotal.adding(.values(from: openEvent))
            return .init(
                closedDate: log.closedEvents.last?.playbackStartDate ?? closedDate,
                closedTotal: closedTotal,
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
                    increment: total.subtracting(metrics.total),
                    total: total
                )
            )
        }
        else if let lastClosedEvent = log.closedEvents.last {
            return .init(
                closedDate: lastClosedEvent.playbackStartDate,
                closedTotal: closedTotal,
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
                    increment: closedTotal.subtracting(metrics.total),
                    total: closedTotal
                )
            )
        }
        else {
            return self
        }
    }

    func updated(with log: AVPlayerItemAccessLog) -> Self {
        updated(with: .init(log, after: closedDate))
    }
}
