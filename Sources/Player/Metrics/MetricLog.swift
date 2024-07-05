//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class MetricLog {
    @Published private(set) var events: [MetricEvent] = []

    func appendEvent(_ event: MetricEvent) {
        events.append(event)
    }

    func eventPublisher() -> AnyPublisher<MetricEvent, Never> {
        $events
            .compactMap(\.last)
            .prepend(events.prefix(max(events.count - 1, 0)))
            .eraseToAnyPublisher()
    }
}
