//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AccessLog {
    let closedEvents: [AccessLogEvent]
    let openEvent: AccessLogEvent?

    init(events: [AccessLogEvent?], after date: Date?) {
        closedEvents = Array(events.prefix(max(events.count - 1, 0))).compactMap { event in
            Self.event(event, after: date)
        }
        if let lastEvent = events.last {
            openEvent = Self.event(lastEvent, after: date)
        }
        else {
            openEvent = nil
        }
    }

    init(_ log: AVPlayerItemAccessLog, after date: Date?) {
        self.init(events: log.events.map { .init($0) }, after: date)
    }

    static func event(_ event: AccessLogEvent?, after date: Date?) -> AccessLogEvent? {
        guard let date, let event, let playbackDate = event.playbackStartDate else { return event }
        return playbackDate > date ? event : nil
    }
}
