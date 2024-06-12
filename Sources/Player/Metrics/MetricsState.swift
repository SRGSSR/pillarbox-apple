//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState {
    static let empty = Self(date: nil, total: .zero, previousOpenEvent: nil, openEvent: nil)

    let date: Date?
    let total: MetricsValues
    let previousOpenEvent: AccessLogEvent?
    let openEvent: AccessLogEvent?

    func updated(with log: AccessLog) -> Self {
        guard let lastClosedEvent = log.closedEvents.last else {
            return .init(date: date, total: total, previousOpenEvent: openEvent, openEvent: log.openEvent)
        }
        let total = log.closedEvents.reduce(total) { initial, next in
            initial.adding(.metrics(from: next))
        }
        return .init(date: lastClosedEvent.playbackStartDate, total: total, previousOpenEvent: openEvent, openEvent: log.openEvent)
    }

    func updated(with log: AVPlayerItemAccessLog) -> Self {
        updated(with: .init(log, after: date))
    }

    func metrics() -> Metrics {
        if let event = openEvent ?? previousOpenEvent {
            return .init(
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
                increment: event.increment(from: previousOpenEvent),
                total: total.adding(.metrics(from: event))
            )
        }
        else {
            return .empty
        }
    }
}
