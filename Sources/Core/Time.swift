//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension CMTimeRange {
    /// Return a time range comparator having some tolerance.
    static func close(within tolerance: CMTime) -> ((CMTimeRange?, CMTimeRange?) -> Bool) {
        precondition(CMTimeCompare(tolerance, .zero) == 1)
        let timeClose = CMTime.close(within: tolerance)
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

    /// Return a time range comparator having some tolerance.
    static func close(within tolerance: TimeInterval) -> ((CMTimeRange?, CMTimeRange?) -> Bool) {
        close(within: CMTimeMakeWithSeconds(tolerance, preferredTimescale: Int32(NSEC_PER_SEC)))
    }
}

public extension CMTime {
    /// Return a time comparator having some tolerance.
    static func close(within tolerance: CMTime) -> ((CMTime?, CMTime?) -> Bool) {
        precondition(CMTimeCompare(.zero, tolerance) != 1)
        return { time1, time2 in
            switch (time1, time2) {
            case (.none, .none):
                return true
            case (.none, .some), (.some, .none):
                return false
            case let (.some(time1), .some(time2)):
                return areClose(time1: time1, time2: time2, within: tolerance)
            }
        }
    }

    /// Return a time comparator having some tolerance.
    static func close(within tolerance: TimeInterval) -> ((CMTime?, CMTime?) -> Bool) {
        close(within: CMTimeMakeWithSeconds(tolerance, preferredTimescale: Int32(NSEC_PER_SEC)))
    }

    private static func areClose(time1: CMTime, time2: CMTime, within tolerance: CMTime) -> Bool {
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
            return CMTimeCompare(CMTimeAbsoluteValue(CMTimeSubtract(time1, time2)), tolerance) != 1
        }
    }
}
