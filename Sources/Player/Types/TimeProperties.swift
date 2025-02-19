//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct TimeProperties: Equatable {
    static let empty = Self(loadedTimeRanges: [], seekableTimeRanges: [], isPlaybackLikelyToKeepUp: false)

    let loadedTimeRanges: [NSValue]
    let seekableTimeRanges: [NSValue]
    let isPlaybackLikelyToKeepUp: Bool
}

extension TimeProperties {
    var seekableTimeRange: CMTimeRange {
        Self.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
    }

    var loadedTimeRange: CMTimeRange {
        Self.timeRange(from: loadedTimeRanges) ?? .invalid
    }

    var buffer: Float {
        let duration = seekableTimeRange.duration
        guard loadedTimeRange.end.isNumeric, duration.isNumeric, duration != .zero else { return 0 }
        return Float(loadedTimeRange.end.seconds / duration.seconds).clamped(to: 0...1)
    }

    static func timeRange(from timeRanges: [NSValue]) -> CMTimeRange? {
        guard let firstRange = timeRanges.first?.timeRangeValue, !firstRange.isIndefinite,
              let lastRange = timeRanges.last?.timeRangeValue, !lastRange.isIndefinite else {
            return nil
        }
        return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
    }

    static func timeRange(loadedTimeRanges: [NSValue], seekableTimeRanges: [NSValue]) -> CMTimeRange {
        guard let timeRange = timeRange(from: seekableTimeRanges) else {
            // Fallback for live MP3.
            return !loadedTimeRanges.isEmpty ? .zero : .invalid
        }
        return timeRange
    }
}
