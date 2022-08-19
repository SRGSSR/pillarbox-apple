//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

enum Time {
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
        return Float(elapsedTime / duration).clamped(to: 0...1)
    }

    /// Return a time comparator having some tolerance.
    static func close(within tolerance: TimeInterval) -> ((CMTime, CMTime) -> Bool) {
        precondition(tolerance >= 0)
        return {
            CMTimeCompare(
                CMTimeAbsoluteValue(CMTimeSubtract($0, $1)),
                CMTimeMakeWithSeconds(tolerance, preferredTimescale: Int32(NSEC_PER_SEC))
            ) == -1
        }
    }

    /// Return a time range comparator having some tolerance.
    static func close(within tolerance: TimeInterval) -> ((CMTimeRange, CMTimeRange) -> Bool) {
        precondition(tolerance >= 0)
        let timeClose: ((CMTime, CMTime) -> Bool) = close(within: tolerance)
        return {
            timeClose($0.start, $1.start) && timeClose($0.end, $1.end)
        }
    }
}
