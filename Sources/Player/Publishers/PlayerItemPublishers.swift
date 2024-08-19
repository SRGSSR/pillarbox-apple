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
            .first(where: \.isLoaded)
            .measureDateInterval()
            .map { dateInterval in
                MetricEvent(
                    kind: .metadataReady(dateInterval),
                    date: dateInterval.end
                )
            }
            .eraseToAnyPublisher()
    }
}
