//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct TimeContext: Equatable {
    static var empty: Self {
        .init(loadedTimeRanges: [], seekableTimeRanges: [])
    }

    let loadedTimeRanges: [NSValue]
    let seekableTimeRanges: [NSValue]

    var timeRange: CMTimeRange {
        Self.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
    }

    static func timeRange(loadedTimeRanges: [NSValue], seekableTimeRanges: [NSValue]) -> CMTimeRange {
        guard let firstRange = seekableTimeRanges.first?.timeRangeValue, !firstRange.isIndefinite,
              let lastRange = seekableTimeRanges.last?.timeRangeValue, !lastRange.isIndefinite else {
            return !loadedTimeRanges.isEmpty ? .zero : .invalid
        }
        return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
    }
}
