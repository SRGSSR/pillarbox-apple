//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct TimedMetadataGroup {
    let items: [MetadataItem]
    let timeRange: CMTimeRange

    func containsTime(_ time: CMTime) -> Bool {
        guard timeRange.duration > CMTime(value: 1, timescale: 1) else { return true }
        return timeRange.containsTime(time)
    }
}
