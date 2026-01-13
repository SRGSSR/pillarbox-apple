//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// Represents a time range.
public struct TimeRange: Hashable {
    /// The range type.
    public enum Kind: Hashable {
        /// Credits.
        case credits(Credits)

        /// Blocked.
        case blocked
    }

    /// The credits type.
    public enum Credits {
        /// Opening.
        case opening

        /// Closing.
        case closing
    }

    let markRange: MarkRange

    /// The kind of the time range.
    public let kind: Kind

    /// The start time of the time range.
    public var start: Mark {
        markRange.start()
    }

    /// The end time of the time range.
    public var end: Mark {
        markRange.end()
    }

    /// The duration of the time range.
    public var duration: CMTime {
        markRange.duration()
    }

    private init(kind: Kind, markRange: MarkRange) {
        self.kind = kind
        self.markRange = markRange
    }

    /// Creates a time range with a start time and duration.
    ///
    /// - Parameters:
    ///   - kind: The kind of the time range.
    ///   - start: The start time of the time range.
    ///   - duration: The start time of the time range.
    public init(kind: Kind, start: CMTime, duration: CMTime) {
        self.init(kind: kind, markRange: .time(.init(start: start, duration: duration)))
    }

    /// Creates a time range from a start and end time.
    ///
    /// - Parameters:
    ///   - kind: The kind of the time range.
    ///   - start: The start time of the time range.
    ///   - end: The end time of the time range.
    public init(kind: Kind, start: CMTime, end: CMTime) {
        self.init(kind: kind, markRange: .time(.init(start: start, end: end)))
    }

    /// Returns a Boolean value that indicates whether the time range contains a time.
    ///
    /// - Parameter time: A time value to test for in the time range.
    /// - Returns: true if the time range contains the time value; otherwise, false.
    public func containsMark(_ mark: Mark) -> Bool {
        markRange.containsMark(mark)
    }

    public func containsPosition(_ position: PlaybackPosition) -> Bool {
        switch markRange {
        case let .time(timeRange):
            timeRange.containsTime(position.time)
        case let .date(dateInterval):
            false // FIXME: UT
        }
    }
}
