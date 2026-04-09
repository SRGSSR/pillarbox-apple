//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore

extension PlayerItem {
    private static func experience<C>(fromService service: ClockInterval<C>, start: C.Instant) -> C.Duration where C: Clock {
        if start < service.start {
            return service.duration
        }
        else if start < service.end {
            return start.duration(to: service.end)
        }
        else {
            return .zero
        }
    }

    func metricEventPublisher() -> AnyPublisher<MetricEvent, Never> {
        $content
            .compactMap(\.serviceInterval)
            .removeDuplicates()
            .withInterval(clock: .suspending)
            .map { service, interval in
                MetricEvent(
                    kind: .metadata(
                        experience: Self.experience(fromService: service, start: interval.start),
                        service: service.duration
                    )
                )
            }
            .eraseToAnyPublisher()
    }
}
