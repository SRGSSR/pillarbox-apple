//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

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
    static func close(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
        precondition(tolerance >= 0)
        return { time1, time2 in
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

enum TimeRange {
    /// Return a time range comparator having some tolerance.
    static func close(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
        precondition(tolerance >= 0)
        let timeClose = Time.close(within: tolerance)
        return {
            timeClose($0.start, $1.start) && timeClose($0.end, $1.end)
        }
    }
}
