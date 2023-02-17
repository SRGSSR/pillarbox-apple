//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVPlayer {
    /// The available time range or `.invalid` when not known.
    var timeRange: CMTimeRange {
        currentItem?.timeRange ?? .invalid
    }

    /// The current item duration or `.invalid` when not known.
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
