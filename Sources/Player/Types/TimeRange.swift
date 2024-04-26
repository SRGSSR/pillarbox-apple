//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// Represents a time range.
public struct TimeRange: Hashable, Equatable {
    /// The range type.
    public enum Kind: Hashable, Equatable {
        /// Credits.
        case credits(Credits)
    }

    /// The credits type.
    public enum Credits {
        /// Opening.
        case opening
        /// Closing.
        case closing
    }

    let timeRange: CMTimeRange

    /// The kind of the time range.
    public let kind: Kind

    /// The start time of the time range.
    public var start: CMTime {
        timeRange.start
    }

    /// The end time of the time range.
    public var end: CMTime {
        timeRange.end
    }

    /// The duration of the time range.
    public var duration: CMTime {
        timeRange.duration
    }

    private init(kind: Kind, timeRange: CMTimeRange) {
        self.kind = kind
        self.timeRange = timeRange
    }

    /// Creates a valid time range with a start time and duration.
    ///
    /// - Parameters:
    ///   - kind: The kind of the time range.
    ///   - start: The start time of the time range.
    ///   - duration: The start time of the time range.
    public init(kind: Kind, start: CMTime, duration: CMTime) {
        self.init(kind: kind, timeRange: .init(start: start, duration: duration))
    }

    /// Creates a valid time range from a start and end time.
    ///
    /// - Parameters:
    ///   - kind: The kind of the time range.
    ///   - start: The start time of the time range.
    ///   - end: The end time of the time range.
    public init(kind: Kind, start: CMTime, end: CMTime) {
        self.init(kind: kind, timeRange: .init(start: start, end: end))
    }

    /// Returns a Boolean value that indicates whether the time range contains a time.
    ///
    /// - Parameter time: A time value to test for in the time range.
    /// - Returns: true if the time range contains the time value; otherwise, false.
    public func containsTime(_ time: CMTime) -> Bool {
        timeRange.containsTime(time)
    }
}
