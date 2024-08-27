//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore

extension PlayerItem {
    static func qoeDateInterval(forQosDateInterval qosDateInterval: DateInterval, startDate: Date) -> DateInterval {
        if startDate < qosDateInterval.end {
            return .init(start: startDate, end: qosDateInterval.end)
        }
        else {
            return .init(start: startDate, duration: 0)
        }
    }

    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        Publishers.CombineLatest(
            $content
                .compactMap(\.dateInterval)
                .removeDuplicates(),
            Just(Date())
        )
        .map { dateInterval, startDate in
            return MetricEvent(
                kind: .metadata(
                    qoe: Self.qoeDateInterval(forQosDateInterval: dateInterval, startDate: startDate),
                    qos: dateInterval
                ),
                date: dateInterval.end
            )
        }
        .eraseToAnyPublisher()
    }
}
