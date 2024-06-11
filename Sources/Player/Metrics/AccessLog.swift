//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AccessLog {
    let previousEvents: [AccessLogEvent]
    let currentEvent: AccessLogEvent?

    init(events: [AccessLogEvent?]) {
        previousEvents = Array(events.prefix(max(events.count - 1, 0))).compactMap { $0 }
        if let lastEvent = events.last {
            currentEvent = lastEvent
        }
        else {
            currentEvent = nil
        }
    }

    init(_ log: AVPlayerItemAccessLog) {
        self.init(events: log.events.map { .init($0) })
    }
}
