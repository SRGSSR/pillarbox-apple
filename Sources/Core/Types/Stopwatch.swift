//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Foundation

/// A stopwatch.
public final class Stopwatch {
    private var date: Date?
    private var total: TimeInterval = 0

    /// Creates a stopwatch.
    public init() {}

    /// Starts the stopwatch.
    public func start() {
        guard date == nil else { return }
        date = .now
    }

    /// Stops the stopwatch.
    public func stop() {
        guard let date else { return }
        total += Date.now.timeIntervalSince(date)
        self.date = nil
    }

    /// The time accumulated by the stopwatch.
    public func time() -> TimeInterval {
        if let date {
            return total + Date.now.timeIntervalSince(date)
        }
        else {
            return total
        }
    }

    /// Resets the stopwatch.
    public func reset() {
        date = nil
        total = 0
    }
}
