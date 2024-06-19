//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import Foundation

/// An object used to capture metrics associated with a player.
public struct Metrics: Equatable {
    /// The player time at the time metrics were captured.
    public let time: CMTime

    // MARK: Server information

    /// The URI of the playback item.
    public let uri: String?

    /// The IP address of the server that was the source of the last delivered media segment.
    public let serverAddress: String?

    // MARK: Playback-related information

    /// The date and time at which playback began.
    public let playbackStartDate: Date?

    /// A GUID that identifies the current playback session.
    public let playbackSessionId: String?

    /// The offset, in seconds, in the playlist where the last uninterrupted period of playback began.
    public let playbackStartOffset: TimeInterval?

    /// The playback type.
    public let playbackType: String?

    /// The accumulated duration, in seconds, until the player item is ready to play.
    public let startupTime: TimeInterval?

    // MARK: Bitrate information

    /// The standard deviation of the observed segment download bit rates.
    ///
    /// Measures actual network download performance.
    public let observedBitrateStandardDeviation: Double?

    /// The throughput, in bits per second, required to play the stream, as advertised by the server.
    public let indicatedBitrate: Double?

    /// The empirical throughput, in bits per second, across all media downloaded.
    ///
    /// Measures actual network download performance. Provides a bandwidth estimate.
    public let observedBitrate: Double?

    /// The audio track’s average bit rate, in bits per second.
    public let averageAudioBitrate: Double?

    /// The video track’s average bit rate, in bits per second.
    public let averageVideoBitrate: Double?

    /// The average throughput, in bits per second, required to play the stream, as advertised by the server.
    public let indicatedAverageBitrate: Double?

    // MARK: Values

    /// The associated increment.
    public let increment: MetricsValues

    /// The associated total.
    public let total: MetricsValues
}
