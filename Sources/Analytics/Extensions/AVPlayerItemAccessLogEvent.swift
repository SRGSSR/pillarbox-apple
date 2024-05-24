//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension AVPlayerItemAccessLogEvent {
    // --------------> MASTER
    //                              indicatedBitrate
    //                                    |
    //                                    v
    // #EXT-X-STREAM-INF:PROGRAM-ID=1,BANDWIDTH=2494507,RESOLUTION=1280x720,FRAME-RATE=50.000,CODECS="avc1.4d4020,mp4a.40.2",VIDEO-RANGE=SDR

    // --------------> CHILD
    //
    // #EXT-X-TARGETDURATION:10
    //          |
    //          v
    // segmentsDownloadedDuration == Chunk size

    /// Info.
    var info: String { // 🔴 (Unusable/Useless) 🟢 (Usable) 🔵 (Accumulate)
        """
        🔵 numberOfMediaRequests ➡️ \(numberOfMediaRequests)
        🔴 playbackStartDate ➡️ \(dateFormat(for: playbackStartDate))
        🟢 uri ➡️ \(uri ?? "")
        🔴 serverAddress ➡️ \(serverAddress ?? "")
        🔴 numberOfServerAddressChanges ➡️ \(numberOfServerAddressChanges)
        🟢 playbackSessionID ➡️ \(playbackSessionID ?? "")
        playbackStartOffset ➡️ \(playbackStartOffset)
        🟢🔵 segmentsDownloadedDuration ➡️ \(segmentsDownloadedDuration)
        🔵 durationWatched ➡️ \(durationWatched)
        🔵 numberOfStalls ➡️ \(numberOfStalls)
        🔵 numberOfBytesTransferred ➡️ \(bytesFormat(for: numberOfBytesTransferred))
        transferDuration ➡️ \(transferDuration)
        observedBitrate ➡️ \(bytesFormat(for: observedBitrate))
        🟢 indicatedBitrate ➡️ \(indicatedBitrate)
        indicatedAverageBitrate ➡️ \(bytesFormat(for: indicatedAverageBitrate))
        averageVideoBitrate ➡️ \(bytesFormat(for: averageVideoBitrate))
        averageAudioBitrate ➡️ \(bytesFormat(for: averageAudioBitrate))
        🔵 numberOfDroppedVideoFrames ➡️ \(numberOfDroppedVideoFrames)
        🟢 startupTime ➡️ \(startupTime)
        downloadOverdue ➡️ \(downloadOverdue)
        observedBitrateStandardDeviation ➡️ \(bytesFormat(for: observedBitrateStandardDeviation))
        🟢 playbackType ➡️ \(playbackType ?? "")
        mediaRequestsWWAN ➡️ \(mediaRequestsWWAN)
        switchBitrate ➡️ \(bytesFormat(for: switchBitrate))
        """
    }

    private func bytesFormat(for property: Any?) -> String {
         let formatter = ByteCountFormatter()
         formatter.countStyle = .binary
         return formatter.string(for: property) ?? "---"
     }

     private func dateFormat(for date: Date?) -> String {
         let formatter = DateFormatter()
         formatter.dateStyle = .long
         return formatter.string(for: date) ?? "---"
     }
}
