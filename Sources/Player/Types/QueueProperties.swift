//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

struct QueueProperties: Equatable {
    static let empty = Self(metadata: .empty, itemProperties: .empty, metricEvents: [])

    let metadata: PlayerMetadata
    let itemProperties: PlayerItemProperties
    let metricEvents: [MetricEvent]
}
