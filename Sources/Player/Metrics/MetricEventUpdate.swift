//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MetricEventUpdate: Equatable {
    static let empty = Self(previousEvents: [], newEvents: [])

    let previousEvents: [MetricEvent]
    let newEvents: [MetricEvent]

    var events: [MetricEvent] {
        previousEvents + newEvents
    }

    func updated(with event: MetricEvent) -> Self {
        .init(
            previousEvents: events,
            newEvents: [event]
        )
    }
}
