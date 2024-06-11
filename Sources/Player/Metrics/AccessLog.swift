//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct AccessLog {
    let previousEvents: [AccessLogEvent]
    let currentEvent: AccessLogEvent?

    init(events: [AccessLogEvent?], after date: Date?) {
        let eventCount = max(events.count - 1, 0)
        previousEvents = Array(events.prefix(eventCount)).compactMap { event in
            Self.event(event, date: date)
        }
        if let lastEvent = events.last {
            currentEvent = Self.event(lastEvent, date: date)
        }
        else {
            currentEvent = nil
        }
    }

    init(_ log: AVPlayerItemAccessLog, after date: Date?) {
        self.init(events: log.events.map { .init($0) }, after: date)
    }

    static func event(_ event: AccessLogEvent?, date: Date?) -> AccessLogEvent? {
        guard let date, let event else { return event }
        return event.playbackStartDate > date ? event : nil
    }
}
