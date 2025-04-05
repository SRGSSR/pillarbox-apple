//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct MetricsCache: Equatable {
    static let empty = Self(count: 0, total: .zero)

    let count: Int
    let total: MetricsValues

    func adding(events: [AccessLogEvent]) -> Self {
        .init(
            count: count + events.count,
            total: events.reduce(total) { $0 + .values(from: $1) }
        )
    }
}
