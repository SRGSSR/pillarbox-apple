//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// Represents a time range of the playback.
public struct PlaybackRange: Equatable {
    /// The range type.
    public enum Kind: Equatable {
        /// A credit.
        case credit(Credit)
    }

    /// The credit type.
    public enum Credit {
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
