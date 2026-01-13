//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia
import PillarboxPlayer

extension Player {
    func skippableTimeRange(at position: PlaybackPosition) -> TimeRange? {
        metadata.timeRanges.first { timeRange in
            if case .credits = timeRange.kind, timeRange.containsPosition(position) {
                return true
            }
            else {
                return false
            }
        }
    }
}
