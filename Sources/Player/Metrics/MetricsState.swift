//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState {
    static let empty = Self(date: nil, total: .zero, lastEvent: nil)
    let date: Date?
    let total: MetricsValues
    let lastEvent: AccessLogEvent?

    func updated(with log: AccessLog) -> Self {
        guard let lastPreviousEvent = log.previousEvents.last else {
            return .init(date: date, total: total, lastEvent: log.currentEvent)
        }
        let total = log.previousEvents.reduce(total) { initial, next in
            initial.adding(next)
        }
        return .init(date: lastPreviousEvent.playbackStartDate, total: total, lastEvent: log.currentEvent)
    }

    func updated(with log: AVPlayerItemAccessLog) -> Self {
        updated(with: .init(log, after: date))
    }

    func metrics() -> Metrics {
        if let lastEvent {
            let increment = MetricsValues.zero.adding(lastEvent)
            return .init(
                uri: lastEvent.uri,
                serverAddress: lastEvent.serverAddress,
                playbackSessionId: lastEvent.playbackSessionId,
                playbackStartDate: lastEvent.playbackStartDate,
                playbackStartOffset: lastEvent.playbackStartOffset,
                playbackType: lastEvent.playbackType,
                startupTime: lastEvent.startupTime,
                observedBitrateStandardDeviation: lastEvent.observedBitrateStandardDeviation,
                indicatedBitrate: lastEvent.indicatedBitrate,
                observedBitrate: lastEvent.observedBitrate,
                averageAudioBitrate: lastEvent.averageAudioBitrate,
                averageVideoBitrate: lastEvent.averageVideoBitrate,
                indicatedAverageBitrate: lastEvent.indicatedAverageBitrate,
                increment: increment,
                total: total.adding(increment)
            )
        }
        else {
            return .empty
        }
    }
}
