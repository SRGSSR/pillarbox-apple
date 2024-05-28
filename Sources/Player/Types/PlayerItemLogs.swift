//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct PlayerItemLogs: Equatable {
    let accessLogEvents: [AVPlayerItemAccessLogEvent]
    let errorLogEvents: [AVPlayerItemErrorLogEvent]

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

    public var prettyPrinted: String {
        """
        🟡 Duration Watched: \(durationWatched)
        """
    }
}
