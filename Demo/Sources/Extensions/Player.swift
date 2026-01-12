//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer

extension Player {
    func skippableTimeRange(at time: CMTime) -> TimeRange? {
        metadata.timeRanges.first { timeRange in
            if case .credits = timeRange.kind, timeRange.containsTime(time) {
                return true
            }
            else {
                return false
            }
        }
    }
}
