//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore

extension PlayerItem {
    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        $content
            .compactMap(\.dateInterval)
            .removeDuplicates()
            .map { dateInterval in
                MetricEvent(
                    kind: .metadata(dateInterval),
                    date: dateInterval.end
                )
            }
            .eraseToAnyPublisher()
    }
}
