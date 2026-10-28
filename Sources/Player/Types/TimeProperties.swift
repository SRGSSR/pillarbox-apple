//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

struct TimeProperties: Equatable {
    static let empty = Self(loadedTimeRanges: [], seekableTimeRanges: [], clockTime: .invalid, isPlaybackLikelyToKeepUp: false)

    private let loadedTimeRanges: [NSValue]
    private let seekableTimeRanges: [NSValue]
    private let clockTime: CMTime

    let isPlaybackLikelyToKeepUp: Bool

    private init(loadedTimeRanges: [NSValue], seekableTimeRanges: [NSValue], clockTime: CMTime, isPlaybackLikelyToKeepUp: Bool) {
        self.loadedTimeRanges = loadedTimeRanges
        self.seekableTimeRanges = seekableTimeRanges
        self.clockTime = clockTime
        self.isPlaybackLikelyToKeepUp = isPlaybackLikelyToKeepUp
    }

    init(loadedTimeRanges: [NSValue], seekableTimeRanges: [NSValue], isPlaybackLikelyToKeepUp: Bool) {
        self.init(
            loadedTimeRanges: loadedTimeRanges,
            seekableTimeRanges: seekableTimeRanges,
            clockTime: CMClockGetTime(CMClockGetHostTimeClock()),
            isPlaybackLikelyToKeepUp: isPlaybackLikelyToKeepUp
        )
    }
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
    var smoothSeekableTimeRange: CMTimeRange {
        let time = CMClockGetTime(CMClockGetHostTimeClock())
        let timeRange = seekableTimeRange
        return .init(start: start(of: timeRange, at: time), end: end(of: timeRange, at: time))
    }

    private func start(of timeRange: CMTimeRange, at time: CMTime) -> CMTime {
        guard clockTime.isValid, timeRange.start != .zero else { return .zero }
        return timeRange.start + time - clockTime
    }

    private func end(of timeRange: CMTimeRange, at time: CMTime) -> CMTime {
        guard clockTime.isValid else { return timeRange.end }
        return timeRange.end + time - clockTime
    }

    func updated(from previous: Self) -> Self {
        .init(
            loadedTimeRanges: loadedTimeRanges,
            seekableTimeRanges: seekableTimeRanges,
            clockTime: (seekableTimeRange.end == previous.seekableTimeRange.end) ? previous.clockTime : clockTime,
            isPlaybackLikelyToKeepUp: isPlaybackLikelyToKeepUp
        )
    }
}
