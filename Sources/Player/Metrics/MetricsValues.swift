//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Values associated with metrics.
public struct MetricsValues: Equatable {
    static let zero = Self(
        numberOfServerAddressChanges: 0,
        mediaRequestsWWAN: 0,
        transferDuration: 0,
        numberOfBytesTransferred: 0,
        numberOfMediaRequests: 0,
        durationWatched: 0,
        numberOfDroppedVideoFrames: 0,
        numberOfStalls: 0,
        segmentsDownloadedDuration: 0,
        downloadOverdue: 0,
        switchBitrate: 0
    )

    // MARK: Getting Server-Related Log Events

    /// A count of changes to the server address over the last uninterrupted period of playback.
    public let numberOfServerAddressChanges: Int

    /// The number of network read requests over a WWAN.
    public let mediaRequestsWWAN: Int

    /// The accumulated duration, in seconds, of active network transfer of bytes.
    public let transferDuration: TimeInterval

    /// The accumulated number of bytes transferred by the current item.
    public let numberOfBytesTransferred: Int64

    /// The number of media read requests from the server to this client.
    public let numberOfMediaRequests: Int

    // MARK: Getting Playback-Related Log Events

    /// The accumulated playback duration of the current item, in seconds.
    public let durationWatched: TimeInterval

    /// The total number of dropped video frames.
    public let numberOfDroppedVideoFrames: Int

    /// The total number of playback stalls encountered.
    public let numberOfStalls: Int

    /// The accumulated duration, in seconds, of the media segments downloaded.
    public let segmentsDownloadedDuration: TimeInterval

    /// The total number of times that downloading the segments took too long.
    public let downloadOverdue: Int

    // MARK: Getting Bit Rate Log Events

    /// The bandwidth value that causes a switch, up or down, in the item's quality being played.
    public let switchBitrate: Double

    static func values(from event: AccessLogEvent) -> Self {
        .init(
            numberOfServerAddressChanges: event.numberOfServerAddressChanges,
            mediaRequestsWWAN: event.mediaRequestsWWAN,
            transferDuration: event.transferDuration,
            numberOfBytesTransferred: event.numberOfBytesTransferred,
            numberOfMediaRequests: event.numberOfMediaRequests,
            durationWatched: event.durationWatched,
            numberOfDroppedVideoFrames: event.numberOfDroppedVideoFrames,
            numberOfStalls: event.numberOfStalls,
            segmentsDownloadedDuration: event.segmentsDownloadedDuration,
            downloadOverdue: event.downloadOverdue,
            switchBitrate: event.switchBitrate
        )
    }
}

extension MetricsValues {
    static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            numberOfServerAddressChanges: lhs.numberOfServerAddressChanges + rhs.numberOfServerAddressChanges,
            mediaRequestsWWAN: lhs.mediaRequestsWWAN + rhs.mediaRequestsWWAN,
            transferDuration: lhs.transferDuration + rhs.transferDuration,
            numberOfBytesTransferred: lhs.numberOfBytesTransferred + rhs.numberOfBytesTransferred,
            numberOfMediaRequests: lhs.numberOfMediaRequests + rhs.numberOfMediaRequests,
            durationWatched: lhs.durationWatched + rhs.durationWatched,
            numberOfDroppedVideoFrames: lhs.numberOfDroppedVideoFrames + rhs.numberOfDroppedVideoFrames,
            numberOfStalls: lhs.numberOfStalls + rhs.numberOfStalls,
            segmentsDownloadedDuration: lhs.segmentsDownloadedDuration + rhs.segmentsDownloadedDuration,
            downloadOverdue: lhs.downloadOverdue + rhs.downloadOverdue,
            switchBitrate: lhs.switchBitrate + rhs.switchBitrate
        )
    }

    static func - (lhs: Self, rhs: Self) -> Self {
        .init(
            numberOfServerAddressChanges: lhs.numberOfServerAddressChanges - rhs.numberOfServerAddressChanges,
            mediaRequestsWWAN: lhs.mediaRequestsWWAN - rhs.mediaRequestsWWAN,
            transferDuration: lhs.transferDuration - rhs.transferDuration,
            numberOfBytesTransferred: lhs.numberOfBytesTransferred - rhs.numberOfBytesTransferred,
            numberOfMediaRequests: lhs.numberOfMediaRequests - rhs.numberOfMediaRequests,
            durationWatched: lhs.durationWatched - rhs.durationWatched,
            numberOfDroppedVideoFrames: lhs.numberOfDroppedVideoFrames - rhs.numberOfDroppedVideoFrames,
            numberOfStalls: lhs.numberOfStalls - rhs.numberOfStalls,
            segmentsDownloadedDuration: lhs.segmentsDownloadedDuration - rhs.segmentsDownloadedDuration,
            downloadOverdue: lhs.downloadOverdue - rhs.downloadOverdue,
            switchBitrate: lhs.switchBitrate - rhs.switchBitrate
        )
    }
}
