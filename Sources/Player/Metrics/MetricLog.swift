//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

actor MetricLog {
    var events: [MetricLogEvent] = []

    func addEvent(_ event: MetricLogEvent) {
        events.append(event)
    }
}
