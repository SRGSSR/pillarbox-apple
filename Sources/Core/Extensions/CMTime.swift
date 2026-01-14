//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension CMTime {
    /// Returns a time comparator having some tolerance.
    static func close(within tolerance: CMTime) -> ((CMTime, CMTime) -> Bool) {
        precondition(CMTimeCompare(.zero, tolerance) != 1)
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
                return CMTimeAbsoluteValue(time1 - time2) <= tolerance
            }
        }
    }

    /// Returns a time comparator having some tolerance.
    static func close(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
        close(within: CMTimeMakeWithSeconds(tolerance, preferredTimescale: Int32(NSEC_PER_SEC)))
    }
}
