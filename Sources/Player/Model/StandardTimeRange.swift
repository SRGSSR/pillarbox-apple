//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct StandardTimeRange: Equatable, Codable {
    let startTime: Int
    let endTime: Int
    let type: String

    private var kind: TimeRange.Kind {
        switch type {
        case "BLOCKED":
            return .blocked
        case "OPENING_CREDITS":
            return .credits(.opening)
        case "CLOSING_CREDITS":
            return .credits(.closing)
        default:
            return .custom(type)
        }
    }

    var timeRange: TimeRange {
        .init(
            kind: kind,
            start: .init(value: CMTimeValue(startTime), timescale: 1000),
            end: .init(value: CMTimeValue(endTime), timescale: 1000)
        )
    }
}
