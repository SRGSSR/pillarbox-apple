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

    /// The error level.
    public let level: Level

    /// The detailed error.
    public let error: Error
}
