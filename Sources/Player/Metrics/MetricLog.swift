//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class MetricLog {
    @Published private(set) var events: [MetricEvent] = []

    private let subject = PassthroughSubject<MetricEvent, Never>()

    var persistentEvents: [MetricEvent] {
        events.filter { $0.isPersistent }
    }

    func clearAll() {
        events.removeAll()
    }

    func clearTransient() {
        events.removeAll(where: { !$0.isPersistent })
    }

    func appendEvent(_ event: MetricEvent) {
        events.append(event)
        subject.send(event)
    }

    func eventPublisher() -> AnyPublisher<MetricEvent, Never> {
        subject.eraseToAnyPublisher()
    }
}
