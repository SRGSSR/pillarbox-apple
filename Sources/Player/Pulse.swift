//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// Player pulse.
struct Pulse {
    /// The current time. Guaranteed to be numeric.
    let time: CMTime
    /// The time range. Guaranteed to be valid.
    let timeRange: CMTimeRange
    /// Item duration. Might be indefinite.
    let itemDuration: CMTime

    var progress: Float {
        progress(for: time)
    }

    init?(time: CMTime, timeRange: CMTimeRange, itemDuration: CMTime) {
        guard time.isNumeric, timeRange.isValid else { return nil }
        self.time = time
        self.timeRange = timeRange
        self.itemDuration = itemDuration
    }

    static func close(within tolerance: CMTime) -> ((Pulse?, Pulse?) -> Bool) {
        return { pulse1, pulse2 in
            switch (pulse1, pulse2) {
            case (.none, .none):
                return true
            case (.none, .some), (.some, .none):
                return false
            case let (.some(pulse1), .some(pulse2)):
                return CMTime.close(within: tolerance)(pulse1.time, pulse2.time)
                    && CMTimeRange.close(within: tolerance)(pulse1.timeRange, pulse2.timeRange)
                    && CMTime.close(within: tolerance)(pulse1.itemDuration, pulse2.itemDuration)
            }
        }
    }

    func progress(for time: CMTime) -> Float {
        guard time.isNumeric && timeRange.isValid && !timeRange.isEmpty else { return 0 }
        let elapsedTime = CMTimeGetSeconds(CMTimeSubtract(time, timeRange.start))
        let duration = CMTimeGetSeconds(timeRange.duration)
        return Float(elapsedTime / duration).clamped(to: 0...1)
    }

    func time(forProgress progress: Float) -> CMTime? {
        guard timeRange.isValid && !timeRange.isEmpty else { return nil }
        let multiplier = Float64(progress.clamped(to: 0...1))
        return CMTimeAdd(timeRange.start, CMTimeMultiplyByFloat64(timeRange.duration, multiplier: multiplier))
    }
}
