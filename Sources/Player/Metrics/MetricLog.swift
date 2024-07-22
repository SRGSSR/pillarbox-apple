//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

final class MetricLog {
    private let subject = CurrentValueSubject<[MetricEvent], Never>([])

    func appendEvent(_ event: MetricEvent) {
        subject.send(subject.value + [event])
    }

    func eventPublisher() -> AnyPublisher<[MetricEvent], Never> {
        subject
            .eraseToAnyPublisher()
    }
}
