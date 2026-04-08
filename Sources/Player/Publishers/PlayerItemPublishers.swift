//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation

extension PlayerItem {
    private static func experience<C>(fromService service: Timing<C>, start: C.Instant) -> C.Duration where C: Clock {
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
        Publishers.CombineLatest(
            $content
                .compactMap(\.timing)
                .removeDuplicates(),
            Just(SuspendingClock.suspending.now)
        )
        .map { timing, start in
            MetricEvent(
                kind: .metadata(
                    experience: Self.experience(fromService: timing, start: start),
                    service: timing.duration
                )
            )
        }
        .eraseToAnyPublisher()
    }
}
