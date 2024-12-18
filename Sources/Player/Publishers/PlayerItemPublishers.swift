//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

extension PlayerItem {
    private static func experience(fromService service: DateInterval, startDate: Date) -> DateInterval {
        if startDate < service.start {
            return service
        }
        else if startDate < service.end {
            return .init(start: startDate, end: service.end)
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
            Just(Date.now)
        )
        .map { dateInterval, startDate in
            MetricEvent(
                kind: .metadata(
                    experience: Self.experience(fromService: dateInterval, startDate: startDate),
                    service: dateInterval
                ),
                date: dateInterval.end
            )
        }
        .eraseToAnyPublisher()
    }
}
