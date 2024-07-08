//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState: Equatable {
    static let empty = Self(time: .invalid, event: nil, total: .zero)

    private let time: CMTime
    private let event: AccessLogEvent?
    private let total: MetricsValues

    func updated(with events: [AccessLogEvent], at time: CMTime) -> Self {
        .init(time: time, event: events.last, total: events.reduce(.zero) { $0 + .values(from: $1) })
    }

    func updated(with events: [AVPlayerItemAccessLogEvent], at time: CMTime) -> Self {
        updated(with: events.map { .init($0) }, at: time)
    }

    func updated(with log: AVPlayerItemAccessLog?, at time: CMTime) -> Self {
        updated(with: log?.events ?? [], at: time)
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
