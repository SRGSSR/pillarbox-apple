//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension CMTimeRange {
    /// Returns a Boolean value that indicates whether the time range is valid and not empty.
    var isValidAndNotEmpty: Bool {
        isValid && !isEmpty
    }

    /// Returns a time range comparator having some tolerance.
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

    /// Returns a time range comparator having some tolerance.
    static func close(within tolerance: TimeInterval) -> ((CMTimeRange?, CMTimeRange?) -> Bool) {
        close(within: CMTimeMakeWithSeconds(tolerance, preferredTimescale: Int32(NSEC_PER_SEC)))
    }
}
