//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct TimeProperties: Equatable {
    static let empty = Self(loadedTimeRanges: [], seekableTimeRanges: [], isPlaybackLikelyToKeepUp: false)

    let loadedTimeRanges: [NSValue]
    let seekableTimeRanges: [NSValue]
    let isPlaybackLikelyToKeepUp: Bool

    /// The seekable time range end before its last update.
    var previousSeekableTimeRangeEnd: CMTime = .invalid

    /// The host time at which the seekable time range end was last updated.
    var seekableTimeRangeEndUpdateTime: CMTime = .invalid
}

extension TimeProperties {
    var seekableTimeRange: CMTimeRange {
        Self.timeRange(loadedTimeRanges: loadedTimeRanges, seekableTimeRanges: seekableTimeRanges)
    }

    var loadedTimeRange: CMTimeRange {
        Self.timeRange(from: loadedTimeRanges) ?? .invalid
    }

    var buffer: Float {
        let duration = seekableTimeRange.duration
        guard loadedTimeRange.end.isNumeric, duration.isNumeric, duration != .zero else { return 0 }
        return Float(loadedTimeRange.end.seconds / duration.seconds).clamped(to: 0...1)
    }

    static func timeRange(from timeRanges: [NSValue]) -> CMTimeRange? {
        guard let firstRange = timeRanges.first?.timeRangeValue, !firstRange.isIndefinite,
              let lastRange = timeRanges.last?.timeRangeValue, !lastRange.isIndefinite else {
            return nil
        }
        return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
    }

    static func timeRange(loadedTimeRanges: [NSValue], seekableTimeRanges: [NSValue]) -> CMTimeRange {
        guard let timeRange = timeRange(from: seekableTimeRanges) else {
            // Fallback for live MP3.
            return !loadedTimeRanges.isEmpty ? .zero : .invalid
        }
        return timeRange
    }
}

extension TimeProperties {
    /// A continuous estimate of the seekable time range end.
    ///
    /// For livestreams the seekable time range end jumps each time a chunk is added. The estimate compensates
    /// for these jumps by moving from the previous end to the current one as time elapses since the last update.
    var smoothedSeekableTimeRangeEnd: CMTime {
        let end = seekableTimeRange.end
        guard previousSeekableTimeRangeEnd.isValid, seekableTimeRangeEndUpdateTime.isValid,
              previousSeekableTimeRangeEnd < end else {
            return end
        }
        let elapsedTime = CMClockGetTime(CMClockGetHostTimeClock()) - seekableTimeRangeEndUpdateTime
        let step = end - previousSeekableTimeRangeEnd
        return previousSeekableTimeRangeEnd + CMTimeClampToRange(elapsedTime, range: .init(start: .zero, end: step))
    }

    /// Returns properties whose seekable time range end history is carried over from previous properties if the
    /// end did not change, or updated otherwise.
    func updated(from previous: Self) -> Self {
        var properties = self
        if seekableTimeRange.end == previous.seekableTimeRange.end {
            properties.previousSeekableTimeRangeEnd = previous.previousSeekableTimeRangeEnd
            properties.seekableTimeRangeEndUpdateTime = previous.seekableTimeRangeEndUpdateTime
        }
        else {
            properties.previousSeekableTimeRangeEnd = previous.seekableTimeRange.end
            properties.seekableTimeRangeEndUpdateTime = CMClockGetTime(CMClockGetHostTimeClock())
        }
        return properties
    }
}
