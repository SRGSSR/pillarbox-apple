//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AccessLog {
    let closedEvents: [AccessLogEvent]
    let openEvent: AccessLogEvent?

    init(events: [AccessLogEvent]) {
        closedEvents = Array(events.prefix(max(events.count - 1, 0)))
        openEvent = events.last
    }

    init(_ log: AVPlayerItemAccessLog, after index: Int) {
        self.init(events: log.events.suffix(from: index).map { .init($0) })
    }
}
