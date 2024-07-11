//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine

final class MetricLog {
    private(set) var events: [MetricEvent] = []

    private let subject = PassthroughSubject<MetricEvent, Never>()
    private var cancellable: AnyCancellable?

    func appendEvent(_ event: MetricEvent) {
        events.append(event)
        subject.send(event)
    }

    func clear() {
        events.removeAll()
    }

    func eventPublisher() -> AnyPublisher<MetricEvent, Never> {
        subject.eraseToAnyPublisher()
    }
}
