//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

struct MetricLog {
    private let eventsSubject = CurrentValueSubject<[MetricEvent], Never>([])

    func addEvent(_ event: MetricEvent) {
        eventsSubject.send(eventsSubject.value + [event])
    }

    func eventsPublisher() -> AnyPublisher<[MetricEvent], Never> {
        eventsSubject.eraseToAnyPublisher()
    }
}
