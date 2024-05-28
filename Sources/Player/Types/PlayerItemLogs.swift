//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct PlayerItemLogs: Equatable {
    let accessLogEvents: [AVPlayerItemAccessLogEvent]
    let errorLogEvents: [AVPlayerItemErrorLogEvent]

    public var firstAccessEventLog: AVPlayerItemAccessLogEvent? {
        accessLogEvents.first
    }

    public var lastAccessEventLog: AVPlayerItemAccessLogEvent? {
        accessLogEvents.last
    }

    public var lastErrorEventLog: AVPlayerItemErrorLogEvent? {
        errorLogEvents.last
    }

    public var durationWatched: TimeInterval {
        accessLogEvents.reduce(into: 0) { watchedTime, log in
            watchedTime += log.durationWatched
        }
    }

    public var numberOfMediaRequests: Int {
        accessLogEvents.reduce(into: 0) { requests, log in
            requests += log.numberOfMediaRequests
        }
    }

    public var numberOfStalls: Int {
        accessLogEvents.reduce(into: 0) { stalls, log in
            stalls += log.numberOfStalls
        }
    }

    public var numberOfBytesTransferred: Int64 {
        accessLogEvents.reduce(into: 0) { bytesTransferred, log in
            bytesTransferred += log.numberOfBytesTransferred
        }
    }

    public var transferredDuration: TimeInterval {
        accessLogEvents.reduce(into: 0) { transferredDuration, log in
            transferredDuration += log.transferDuration
        }
    }

    public var networkBytesTransferred: Double {
        guard transferredDuration > 0 else { return 0 }
        return Double(numberOfBytesTransferred) * 8 / transferredDuration
    }

    public var prettyPrinted: String {
        """
        🟢 Session ID: \(lastAccessEventLog?.playbackSessionID ?? "")
        🟢 URI: \(lastAccessEventLog?.uri ?? "")
        🟢 Startup time: \(firstAccessEventLog?.startupTime ?? 0)
        🔵 Duration Watched: \(durationWatched)
        🔵 Number of media requests: \(numberOfMediaRequests)
        🔵 Number of stalls: \(numberOfStalls)
        🔵 Number of bytes transferred: \(bytesFormat(for: numberOfBytesTransferred))
        🔵 Transferred duration: \(transferredDuration)
        🟡 Network bandwidth: \(bytesFormat(for: networkBytesTransferred))
        """
    }
}

private extension PlayerItemLogs {
    func bytesFormat(for property: Any?) -> String {
         let formatter = ByteCountFormatter()
         formatter.countStyle = .binary
         return formatter.string(for: property) ?? "---"
     }
}