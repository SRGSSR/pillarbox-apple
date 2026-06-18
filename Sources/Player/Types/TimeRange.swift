//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// Represents a time range.
public struct TimeRange: Codable, Hashable {
    /// The range type.
    public enum Kind: Codable, Hashable {
        /// Credits.
        case credits(Credits)

        /// Blocked.
        case blocked

        /// Custom.
        case custom(String)
    }

    /// The credits type.
    public enum Credits: Codable {
        /// Opening.
        case opening

        /// Closing.
        case closing
    }

    private let startTimeMs: Int64
    private let endTimeMs: Int64

    /// The kind of the time range.
    public let kind: Kind

    /// The start time of the time range.
    public var start: CMTime {
        .init(value: startTimeMs, timescale: 1000)
    }

    /// The end time of the time range.
    public var end: CMTime {
        .init(value: endTimeMs, timescale: 1000)
    }

    /// The duration of the time range.
    public var duration: CMTime {
        timeRange.duration
    }

    private var timeRange: CMTimeRange {
        .init(start: start, end: end)
    }

    private init(kind: Kind, timeRange: CMTimeRange) {
        self.kind = kind
        self.startTimeMs = Int64(timeRange.start.seconds * 1000)
        self.endTimeMs = Int64(timeRange.end.seconds * 1000)
    }

    /// Creates a time range with a start time and duration.
    ///
    /// - Parameters:
    ///   - kind: The kind of the time range.
    ///   - start: The start time of the time range.
    ///   - duration: The start time of the time range.
    public init(kind: Kind, start: CMTime, duration: CMTime) {
        self.init(kind: kind, timeRange: .init(start: start, duration: duration))
    }

    /// Creates a time range from a start and end time.
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
