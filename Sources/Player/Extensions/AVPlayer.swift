//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVPlayer {
    /// The available time range.
    ///
    /// Returns `.invalid` when the time range is unknown.
    var timeRange: CMTimeRange {
        currentItem?.timeRange ?? .invalid
    }

    /// The current item duration.
    ///
    /// Returns `.invalid` when the duration is unknown.
    var itemDuration: CMTime {
        guard let currentItem else { return .invalid }
        let duration = currentItem.duration
        if duration.isNumeric || currentItem.status == .readyToPlay {
            return duration
        }
        else {
            return .invalid
        }
    }
}
