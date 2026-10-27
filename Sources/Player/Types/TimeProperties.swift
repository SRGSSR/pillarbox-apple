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
    /// Returns a continuous estimate of the seekable time range end.
    ///
    /// - Parameter chunkDuration: The chunk duration.
    /// - Returns: The estimated end.
    ///
    /// For livestreams the seekable time range end jumps by about a chunk duration each time a chunk is added.
    /// The estimate compensates for these jumps by having the end lag a chunk behind, catching up with time
    /// elapsed since the last update.
    func smoothedSeekableTimeRangeEnd(chunkDuration: CMTime) -> CMTime {
        let end = seekableTimeRange.end
        guard chunkDuration.isValid, seekableTimeRangeEndUpdateTime.isValid else { return end }
        let elapsedTime = CMClockGetTime(CMClockGetHostTimeClock()) - seekableTimeRangeEndUpdateTime
        return end - chunkDuration + CMTimeClampToRange(elapsedTime, range: .init(start: .zero, end: chunkDuration))
    }

    /// Returns properties whose seekable time range end update time is carried over from previous properties
    /// if the end did not change.
    func updated(from previous: Self) -> Self {
        var properties = self
        if seekableTimeRange.end == previous.seekableTimeRange.end {
            properties.seekableTimeRangeEndUpdateTime = previous.seekableTimeRangeEndUpdateTime
        }
        else {
            properties.seekableTimeRangeEndUpdateTime = CMClockGetTime(CMClockGetHostTimeClock())
        }
        return properties
    }
}
