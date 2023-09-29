//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct TimeProperties: Equatable {
    static var empty: Self {
        .init(loadedTimeRanges: [], seekableTimeRanges: [])
    }

    let loadedTimeRanges: [NSValue]
    let seekableTimeRanges: [NSValue]

    var seekableTimeRange: CMTimeRange {
        Self.timeRange(from: seekableTimeRanges)
    }

    var loadedTimeRange: CMTimeRange {
        Self.timeRange(from: loadedTimeRanges)
    }

    static func timeRange(from timeRanges: [NSValue]) -> CMTimeRange {
        guard let firstRange = timeRanges.first?.timeRangeValue, !firstRange.isIndefinite,
              let lastRange = timeRanges.last?.timeRangeValue, !lastRange.isIndefinite else {
            return .invalid
        }
        return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
    }
}
