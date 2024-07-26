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
            .first { !$0.resource.isFailing && !$0.resource.isLoading }
            .measureDateInterval()
            .map { dateInterval in
                MetricEvent(
                    kind: .assetLoading(dateInterval),
                    date: dateInterval.end
                )
            }
            .eraseToAnyPublisher()
    }
}
