//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore

extension PlayerItem {
    // FIXME: Should probably also be delivered when restarting the same item (with values 0)
    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        $content
            .dropFirst()
            .first { $0.isLoaded }
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
