//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// An object used to capture metrics associated with a player.
public struct Metrics: Equatable {
    static let empty = Self(
        uri: nil,
        serverAddress: nil,
        playbackSessionId: nil,
        playbackStartDate: nil,
        playbackStartOffset: nil,
        playbackType: nil,
        startupTime: nil,
        observedBitrateStandardDeviation: nil,
        indicatedBitrate: nil,
        observedBitrate: nil,
        averageAudioBitrate: nil,
        averageVideoBitrate: nil,
        indicatedAverageBitrate: nil,
        increment: .zero,
        total: .zero
    )

    // MARK: Getting Server-Related Log Events

    /// The URI of the playback item.
    public let uri: String?

    /// The IP address of the server that was the source of the last delivered media segment.
    public let serverAddress: String?

    /// A GUID that identifies the current playback session.
    public let playbackSessionId: String?

    // MARK: Getting Playback-Related Log Events

    /// The date and time at which playback began.
    public let playbackStartDate: Date?

    /// The offset, in seconds, in the playlist where the last uninterrupted period of playback began.
    public let playbackStartOffset: TimeInterval?

    /// The playback type.
    public let playbackType: String?

    /// The accumulated duration, in seconds, until the player item is ready to play.
    public let startupTime: TimeInterval?

    // MARK: Getting Bit Rate Log Events
    // The observed properties measure actual network download performance and indicated properties measure the bit rate of the media.

    /// The standard deviation of the observed segment download bit rates.
    public let observedBitrateStandardDeviation: Double?

    /// The throughput, in bits per second, required to play the stream, as advertised by the server.
    public let indicatedBitrate: Double?

    /// The empirical throughput, in bits per second, across all media downloaded (bandwidth).
    public let observedBitrate: Double?

    /// The audio track’s average bit rate, in bits per second.
    public let averageAudioBitrate: Double?

    /// The video track’s average bit rate, in bits per second.
    public let averageVideoBitrate: Double?

    /// The average throughput, in bits per second, required to play the stream, as advertised by the server.
    public let indicatedAverageBitrate: Double?

    /// The associated increment.
    public let increment: MetricsValues

    /// The associated total.
    public let total: MetricsValues
}

extension Metrics {
    func updated(with event: AccessLogEvent, total: MetricsValues) -> Metrics {
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
            increment: total.subtracting(self.total),
            total: total
        )
    }
}
