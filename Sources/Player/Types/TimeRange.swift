//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// Represents a time range.
public struct TimeRange: Equatable {
    /// The range type.
    public enum Kind: Equatable {
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

    /// The range type.
    public let kind: Kind

    /// The range.
    public let timeRange: CMTimeRange

    /// Initialize a playback time range.
    /// - Parameters:
    ///   - kind: The range.
    ///   - timeRange: The range type.
    public init(kind: Kind, timeRange: CMTimeRange) {
        self.kind = kind
        self.timeRange = timeRange
    }
}
