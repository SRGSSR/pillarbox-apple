//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Contains a time interval associated with a clock.
public struct ClockInterval<C>: Equatable where C: Clock {
    /// The start of the interval.
    public let start: C.Instant

    /// The duration of the interval.
    public let duration: C.Duration

    /// The end of the interval.
    public var end: C.Instant {
        start.advanced(by: duration)
    }
}

public extension ClockInterval where C.Duration == Duration {
    /// The duration as a time interval.
    func timeInterval() -> TimeInterval {
        duration.timeInterval()
    }
}
