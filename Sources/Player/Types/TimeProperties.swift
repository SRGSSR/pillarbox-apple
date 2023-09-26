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
        Self.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
    }

    var loadedTimeRange: CMTimeRange {
        let start = loadedTimeRanges.first?.timeRangeValue.start ?? .zero
        let end = loadedTimeRanges.last?.timeRangeValue.end ?? .zero
        return CMTimeRangeFromTimeToTime(start: start, end: end)
    }

    static func timeRange(loadedTimeRanges: [NSValue], seekableTimeRanges: [NSValue]) -> CMTimeRange {
        guard let firstRange = seekableTimeRanges.first?.timeRangeValue, !firstRange.isIndefinite,
              let lastRange = seekableTimeRanges.last?.timeRangeValue, !lastRange.isIndefinite else {
            return !loadedTimeRanges.isEmpty ? .zero : .invalid
        }
        return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
    }
}
