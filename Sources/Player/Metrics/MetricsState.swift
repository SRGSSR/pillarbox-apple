//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState {
    static let empty = Self(date: nil, total: .zero, openEvent: nil, previousOpenEvent: nil)
    let date: Date?
    let total: MetricsValues
    let openEvent: AccessLogEvent?
    let previousOpenEvent: AccessLogEvent?

    func updated(with log: AccessLog) -> Self {
        guard let lastClosedEvent = log.closedEvents.last else {
            return .init(date: date, total: total, openEvent: log.openEvent, previousOpenEvent: openEvent)
        }
        let total = log.closedEvents.reduce(total) { initial, next in
            initial.adding(next)
        }
        return .init(date: lastClosedEvent.playbackStartDate, total: total, openEvent: log.openEvent, previousOpenEvent: openEvent)
    }

    func updated(with log: AVPlayerItemAccessLog) -> Self {
        updated(with: .init(log, after: date))
    }

    func metrics() -> Metrics {
        if let openEvent {
            return .init(
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
                increment: openEvent.increment(from: previousOpenEvent),
                total: total.adding(.zero.adding(openEvent))
            )
        }
        else {
            return .empty
        }
    }
}
