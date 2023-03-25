//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVPlayerItem {
    var timeRange: CMTimeRange {
        Self.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
    }

    static func playerItems(from items: [PlayerItem]) -> [AVPlayerItem] {
        playerItems(from: items.map(\.asset))
    }

    static func timeRange(loadedTimeRanges: [NSValue], seekableTimeRanges: [NSValue]) -> CMTimeRange {
        guard let firstRange = seekableTimeRanges.first?.timeRangeValue, !firstRange.isIndefinite,
              let lastRange = seekableTimeRanges.last?.timeRangeValue, !lastRange.isIndefinite else {
            return !loadedTimeRanges.isEmpty ? .zero : .invalid
        }
        return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
    }
}
