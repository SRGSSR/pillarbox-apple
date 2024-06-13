//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

struct MetricsCache: Equatable {
    static let empty = Self(date: nil, total: .zero)

    let date: Date?
    let total: MetricsValues

    func updated(with events: [AccessLogEvent]) -> Self {
        guard let lastEvent = events.last else { return self }
        return .init(
            date: lastEvent.playbackStartDate,
            total: events.reduce(total) { initial, next in
                initial.adding(.values(from: next))
            }
        )
    }
}
