//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class MetricLog {
    private(set) var events: [MetricEvent] = []

    private let subject = PassthroughSubject<MetricEvent, Never>()
    private let joinedSubject = PassthroughSubject<MetricEvent, Never>()

    private var cancellable: AnyCancellable?

    func appendEvent(_ event: MetricEvent) {
        events.append(event)
        subject.send(event)
    }

    func clear() {
        events.removeAll()
    }

    func eventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Publishers.Merge(
            subject,
            joinedSubject
        )
        .prepend(events)
        .eraseToAnyPublisher()
    }

    func join(with other: MetricLog?) {
        cancellable = other?.eventPublisher()
            .subscribe(joinedSubject)
    }
}
