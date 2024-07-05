//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

/// The payload associated with an error metric event.
public struct ErrorMetricPayload {
    /// An error level.
    public enum Level: String {
        /// Fatal.
        case fatal

        /// Warning.
        case warning
    }

    /// An error domain.
    public enum Domain: String {
        /// Asset-related.
        case asset

        /// Resource-related.
        case resource
    }

    /// The error level.
    public let level: Level

    /// The error domain.
    public let domain: Domain

    /// The detailed error.
    public let error: Error
}
