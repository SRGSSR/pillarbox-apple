//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension Player {
    static func timeRange(for item: AVPlayerItem?) -> CMTimeRange {
        guard let item,
              let firstRange = item.seekableTimeRanges.first?.timeRangeValue,
              let lastRange = item.seekableTimeRanges.last?.timeRangeValue else {
            return .zero
        }
        return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
    }

    static func progress(for time: CMTime, in range: CMTimeRange) -> Float {
        guard range.isValid && !range.isEmpty else { return 0 }
        let elapsedTime = CMTimeGetSeconds(CMTimeSubtract(time, range.start))
        let duration = CMTimeGetSeconds(range.duration)
        return Float(elapsedTime / duration)
    }
}
