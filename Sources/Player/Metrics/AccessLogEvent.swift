//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

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

    init?(
        playbackStartDate: Date?,
        uri: String?,
        serverAddress: String?,
        playbackSessionId: String?,
        playbackStartOffset: TimeInterval,
        playbackType: String?,
        startupTime: TimeInterval,
        observedBitrateStandardDeviation: Double,
        indicatedBitrate: Double,
        observedBitrate: Double,
        averageAudioBitrate: Double,
        averageVideoBitrate: Double,
        indicatedAverageBitrate: Double,
        numberOfServerAddressChanges: Int,
        mediaRequestsWWAN: Int,
        transferDuration: TimeInterval,
        numberOfBytesTransferred: Int64,
        numberOfMediaRequests: Int,
        durationWatched: TimeInterval,
        numberOfDroppedVideoFrames: Int,
        numberOfStalls: Int,
        segmentsDownloadedDuration: TimeInterval,
        downloadOverdue: Int,
        switchBitrate: Double
    ) {
        guard let playbackStartDate else { return nil }
        self.playbackStartDate = playbackStartDate

        self.uri = uri
        self.serverAddress = serverAddress
        self.playbackSessionId = playbackSessionId
        self.playbackStartOffset = Self.optional(playbackStartOffset)
        self.playbackType = playbackType
        self.startupTime = Self.optional(startupTime)
        self.observedBitrateStandardDeviation = Self.optional(observedBitrateStandardDeviation)
        self.indicatedBitrate = Self.optional(indicatedBitrate)
        self.observedBitrate = Self.optional(observedBitrate)
        self.averageAudioBitrate = Self.optional(averageAudioBitrate)
        self.averageVideoBitrate = Self.optional(averageVideoBitrate)
        self.indicatedAverageBitrate = Self.optional(indicatedAverageBitrate)

        self.numberOfServerAddressChanges = Self.nonNegative(numberOfServerAddressChanges)
        self.mediaRequestsWWAN = Self.nonNegative(mediaRequestsWWAN)
        self.transferDuration = Self.nonNegative(transferDuration)
        self.numberOfBytesTransferred = Self.nonNegative(numberOfBytesTransferred)
        self.numberOfMediaRequests = Self.nonNegative(numberOfMediaRequests)
        self.durationWatched = Self.nonNegative(durationWatched)
        self.numberOfDroppedVideoFrames = Self.nonNegative(numberOfDroppedVideoFrames)
        self.numberOfStalls = Self.nonNegative(numberOfStalls)
        self.segmentsDownloadedDuration = Self.nonNegative(segmentsDownloadedDuration)
        self.downloadOverdue = Self.nonNegative(downloadOverdue)
        self.switchBitrate = Self.nonNegative(switchBitrate)
    }
}

extension AccessLogEvent {
    init?(_ event: AVPlayerItemAccessLogEvent) {
        self.init(
            playbackStartDate: event.playbackStartDate,
            uri: event.uri,
            serverAddress: event.serverAddress,
            playbackSessionId: event.playbackSessionID,
            playbackStartOffset: event.playbackStartOffset,
            playbackType: event.playbackType,
            startupTime: event.startupTime,
            observedBitrateStandardDeviation: event.observedBitrateStandardDeviation,
            indicatedBitrate: event.indicatedBitrate,
            observedBitrate: event.observedBitrate,
            averageAudioBitrate: event.averageAudioBitrate,
            averageVideoBitrate: event.averageVideoBitrate,
            indicatedAverageBitrate: event.indicatedAverageBitrate,
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

extension AccessLogEvent {
    static func nonNegative<T>(_ value: T) -> T where T: Comparable & SignedNumeric {
        max(value, .zero)
    }

    static func optional<T>(_ value: T) -> T? where T: Comparable & SignedNumeric {
        value < .zero ? nil : value
    }

    func increment(from event: Self?) -> MetricsValues {
        // TODO: Refact
        if let event {
            .init(
                numberOfServerAddressChanges: numberOfServerAddressChanges - event.numberOfServerAddressChanges,
                mediaRequestsWWAN: mediaRequestsWWAN - event.mediaRequestsWWAN,
                transferDuration: transferDuration - event.transferDuration,
                numberOfBytesTransferred: numberOfBytesTransferred - event.numberOfBytesTransferred,
                numberOfMediaRequests: numberOfMediaRequests - event.numberOfMediaRequests,
                durationWatched: durationWatched - event.durationWatched,
                numberOfDroppedVideoFrames: numberOfDroppedVideoFrames - event.numberOfDroppedVideoFrames,
                numberOfStalls: numberOfStalls - event.numberOfStalls,
                segmentsDownloadedDuration: segmentsDownloadedDuration - event.segmentsDownloadedDuration,
                downloadOverdue: downloadOverdue - event.downloadOverdue,
                switchBitrate: switchBitrate - event.switchBitrate
            )
        }
        else {
            .init(
                numberOfServerAddressChanges: numberOfServerAddressChanges,
                mediaRequestsWWAN: mediaRequestsWWAN,
                transferDuration: transferDuration,
                numberOfBytesTransferred: numberOfBytesTransferred,
                numberOfMediaRequests: numberOfMediaRequests,
                durationWatched: durationWatched,
                numberOfDroppedVideoFrames: numberOfDroppedVideoFrames,
                numberOfStalls: numberOfStalls,
                segmentsDownloadedDuration: segmentsDownloadedDuration,
                downloadOverdue: downloadOverdue,
                switchBitrate: switchBitrate
            )
        }
    }
}
