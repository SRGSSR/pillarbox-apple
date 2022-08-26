//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

@testable import Player

import CoreMedia
import Circumspect

extension Pulse: Similar {
    public static func ~= (lhs: Pulse, rhs: Pulse) -> Bool {
        Time.close(within: 0.5)(lhs.time, rhs.time) && TimeRange.close(within: 0.5)(lhs.timeRange, rhs.timeRange)
    }
}

func beClose(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
    Time.close(within: tolerance)
}

func beClose(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
    TimeRange.close(within: tolerance)
}
