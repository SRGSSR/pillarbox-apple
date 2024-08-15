//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct MetricsState: Equatable {
    static let empty = Self(with: [], at: .invalid)

    private let time: CMTime
    private let event: AccessLogEvent?
    private let total: MetricsValues

    init(with events: [AccessLogEvent], at time: CMTime) {
        self.time = time
        self.event = events.last
        self.total = events.reduce(.zero) { $0 + .values(from: $1) }
    }

    init?(from item: AVPlayerItem) {
        guard let events = item.accessLog()?.events, !events.isEmpty else { return nil }
        self.init(with: events.map { AccessLogEvent($0) }, at: item.currentTime())
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
