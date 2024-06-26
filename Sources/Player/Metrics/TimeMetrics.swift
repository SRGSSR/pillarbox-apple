//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Time metrics.
public struct TimeMetrics {
    /// The start time.
    public let startTime: Date

    /// The end time.
    public let endTime: Date

    /// The duration.
    public var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
}
