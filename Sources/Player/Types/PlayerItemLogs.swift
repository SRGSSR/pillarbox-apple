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
}
