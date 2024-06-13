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
        events.reduce(self) { initial, next in
            .init(
                date: next.playbackStartDate,
                total: total.adding(.values(from: next))
            )
        }
    }
}
