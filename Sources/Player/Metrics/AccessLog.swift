//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AccessLog {
    let events: [AccessLogEvent]

    init(events: [AccessLogEvent]) {
        self.events = events
    }

    init(_ log: AVPlayerItemAccessLog, after index: Int) {
        self.init(events: log.events.map { .init($0) })
    }
}
