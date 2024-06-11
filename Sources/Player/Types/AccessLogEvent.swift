//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct AccessLogEvent {
    let playbackStartDate: Date

    // MARK: Optional information

    let uri: String?
    let serverAddress: String?
    let playbackSessionId: String?
    let playbackStartOffset: TimeInterval?
    let playbackType: String?
    let startupTime: TimeInterval?
    let observedBitrateStandardDeviation: Double?
    let indicatedBitrate: Double?
    let observedBitrate: Double?
    let averageAudioBitrate: Double?
    let averageVideoBitrate: Double?
    let indicatedAverageBitrate: Double?

    // MARK: Additive information

    let numberOfServerAddressChanges: Int
    let mediaRequestsWWAN: Int
    let transferDuration: TimeInterval
    let numberOfBytesTransferred: Int64
    let numberOfMediaRequests: Int
    let durationWatched: TimeInterval
    let numberOfDroppedVideoFrames: Int
    let numberOfStalls: Int
    let segmentsDownloadedDuration: TimeInterval
    let downloadOverdue: Int
    let switchBitrate: Double
}
