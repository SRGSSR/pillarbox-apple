//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import PillarboxCore

extension PlayerItem {
    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Empty().eraseToAnyPublisher()
        // TODO:
        //   - Define \.isLoaded property on Resource
        //   - Produce stream of values via slice, detect change to true.
//        $content
//            .measureDateInterval()
//            .map { dateInterval in
//                MetricEvent(
//                    kind: .assetLoading(dateInterval),
//                    date: dateInterval.end
//                )
//            }
//            .eraseToAnyPublisher()
    }
}
