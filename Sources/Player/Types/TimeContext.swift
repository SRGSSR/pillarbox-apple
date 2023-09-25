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

    // TODO: Rename as `seekableTimeRange` and make func?
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

    func loadedTimeRange() -> CMTimeRange {
        let start = loadedTimeRanges.first?.timeRangeValue.start ?? .zero
        let end = loadedTimeRanges.last?.timeRangeValue.end ?? .zero
        return CMTimeRangeFromTimeToTime(start: start, end: end)
    }
}
