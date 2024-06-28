//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class MetricLog {
    private var events: [MetricLogEvent] = []

    private let eventsSubject = PassthroughSubject<[MetricLogEvent], Never>()

    func addEvent(_ event: MetricLogEvent) {
        events += [event]
        eventsSubject.send(events)
    }

    func eventsPublisher() -> AnyPublisher<[MetricLogEvent], Never> {
        eventsSubject.eraseToAnyPublisher()
    }
}
