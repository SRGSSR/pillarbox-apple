//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MetricEventUpdate {
    static let empty = Self(previousEvents: [], newEvents: [])

    let previousEvents: [MetricEvent]
    let newEvents: [MetricEvent]

    var events: [MetricEvent] {
        previousEvents + newEvents
    }

    init(previousEvents: [MetricEvent], newEvents: [MetricEvent]) {
        self.previousEvents = previousEvents.sorted { $0.date < $1.date }
        self.newEvents = newEvents.sorted { $0.date < $1.date }
    }

    func updated(with event: MetricEvent) -> Self {
        .init(previousEvents: events, newEvents: [event])
    }
}
