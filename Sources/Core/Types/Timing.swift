//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// Contains timing information for an event.
public struct Timing<C>: Equatable where C: Clock {
    /// The start of the event.
    public let start: C.Instant

    /// The duration of the event.
    public let duration: C.Duration

    /// The end of the event.
    public var end: C.Instant {
        start.advanced(by: duration)
    }
}

public extension Timing where C.Duration == Duration {
    /// The duration as a time interval.
    func timeInterval() -> TimeInterval {
        duration.timeInterval()
    }
}
