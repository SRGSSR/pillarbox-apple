//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class MetricLog {
    private let eventsSubject = CurrentValueSubject<[MetricLogEvent], Never>([])

    func addEvent(_ event: MetricLogEvent) {
        eventsSubject.send(eventsSubject.value + [event])
    }

    func eventsPublisher() -> AnyPublisher<[MetricLogEvent], Never> {
        eventsSubject.eraseToAnyPublisher()
    }
}
