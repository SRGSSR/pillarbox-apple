//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public struct TimedMetadataGroup {
    public let items: [MetadataItem]
    private let timeRange: CMTimeRange

    init(items: [MetadataItem], timeRange: CMTimeRange) {
        self.items = items
        self.timeRange = timeRange
    }

    public func containsTime(_ time: CMTime) -> Bool {
        guard timeRange.duration > CMTime(value: 1, timescale: 1) else { return true }
        return timeRange.containsTime(time)
    }
}
