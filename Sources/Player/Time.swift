//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

enum TimeRange {
    /// Return a time range comparator having some tolerance.
    static func close(within tolerance: TimeInterval) -> ((CMTimeRange?, CMTimeRange?) -> Bool) {
        precondition(tolerance >= 0)
        let timeClose = Time.close(within: tolerance)
        return { timeRange1, timeRange2 in
            switch (timeRange1, timeRange2) {
            case (.none, .none):
                return true
            case (.none, .some), (.some, .none):
                return false
            case let (.some(timeRange1), .some(timeRange2)):
                return timeClose(timeRange1.start, timeRange2.start) && timeClose(timeRange1.duration, timeRange2.duration)
            }
        }
    }
}

enum Time {
    static func timeRange(for item: AVPlayerItem?) -> CMTimeRange? {
        guard let item else {
            return nil
        }
        guard let firstRange = item.seekableTimeRanges.first?.timeRangeValue,
              let lastRange = item.seekableTimeRanges.last?.timeRangeValue else {
            return !item.loadedTimeRanges.isEmpty ? .zero : nil
        }
        return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
    }

    /// Return a time comparator having some tolerance. `CMTime` implements standard equality and comparison operators
    /// in Swift for convenience.
    static func close(within tolerance: TimeInterval) -> ((CMTime?, CMTime?) -> Bool) {
        precondition(tolerance >= 0)
        return { time1, time2 in
            switch (time1, time2) {
            case (.none, .none):
                return true
            case (.none, .some), (.some, .none):
                return false
            case let (.some(time1), .some(time2)):
                if time1.isPositiveInfinity && time2.isPositiveInfinity {
                    return true
                }
                else if time1.isNegativeInfinity && time2.isNegativeInfinity {
                    return true
                }
                else if time1.isIndefinite && time2.isIndefinite {
                    return true
                }
                else if !time1.isValid && !time2.isValid {
                    return true
                }
                else {
                    return CMTimeAbsoluteValue(CMTimeSubtract(time1, time2))
                        <= CMTimeMakeWithSeconds(tolerance, preferredTimescale: Int32(NSEC_PER_SEC))
                }
            }
        }
    }
}
