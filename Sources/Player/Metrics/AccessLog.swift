//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AccessLog {
    let closedEvents: [AccessLogEvent]
    let openEvent: AccessLogEvent?

    init(events: [AccessLogEvent], after index: Int) {
        if index < events.count {
            closedEvents = Array(events[index..<events.count - 1])
            openEvent = events.last
        }
        else {
            closedEvents = []
            openEvent = nil
        }
    }

    init(_ log: AVPlayerItemAccessLog, after index: Int) {
        self.init(events: log.events.map { .init($0) }, after: index)
    }
}
