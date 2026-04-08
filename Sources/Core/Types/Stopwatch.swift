//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A stopwatch.
public final class Stopwatch<C> where C: Clock {
    private let clock: C

    private var instant: C.Instant?
    private var total: C.Duration = .zero

    /// Creates a stopwatch.
    public init(clock: C = .continuous) {
        self.clock = clock
    }

    /// Starts the stopwatch.
    public func start() {
        guard instant == nil else { return }
        instant = clock.now
    }

    /// Stops the stopwatch.
    public func stop() {
        guard let instant else { return }
        total += instant.duration(to: clock.now)
        self.instant = nil
    }

    /// The duration accumulated by the stopwatch.
    public func duration() -> C.Duration {
        if let instant {
            return total + instant.duration(to: clock.now)
        }
        else {
            return total
        }
    }

    /// Resets the stopwatch.
    public func reset() {
        instant = nil
        total = .zero
    }
}

public extension Stopwatch where C.Duration == Duration {
    /// The duration accumulated by the stopwatch, as a time interval.
    func timeInterval() -> TimeInterval {
        duration().timeInterval()
    }
}
