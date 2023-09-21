//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension AVPlayerItem {
    var timeRange: CMTimeRange {
        TimeContext.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
    }

    static func playerItems(from items: [PlayerItem]) -> [AVPlayerItem] {
        playerItems(from: items.map(\.asset))
    }
}
