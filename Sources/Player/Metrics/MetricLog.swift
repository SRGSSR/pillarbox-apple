//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

class MetricLog {
    var events: [MetricEvent] = []
    private let eventsSubject = PassthroughSubject<MetricEvent, Never>()

    func addEvent(_ event: MetricEvent) {
        events.append(event)
        eventsSubject.send(event)
    }

    func eventsPublisher() -> AnyPublisher<MetricEvent, Never> {
        eventsSubject
            .prepend(events)
            .eraseToAnyPublisher()
    }
}
