//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

/// A description for a position to reach.
public struct Position {
    enum Value {
        case time(CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime)
        case date(Date)
    }

    let value: Value

    fileprivate init(time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) {
        self.value = .time(time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
    }

    fileprivate init(date: Date) {
        self.value = .date(date)
    }

    func after(_ markRanges: [MarkRange]) -> Self? {
        switch value {
        case let .time(time, _, toleranceAfter):
            guard let timeAfter = time.after(timeRanges: markRanges.compactMap { $0.timeRange() }) else { return nil }
            return .init(time: timeAfter, toleranceBefore: .zero, toleranceAfter: toleranceAfter)
        case let .date(date):
            return nil // FIXME: UT
        }
    }

    func mark() -> Mark {
        switch value {
        case let .time(time, _, _):
            .time(time)
        case let .date(date):
            .date(date)
        }
    }

    func isValid() -> Bool {
        switch value {
        case let .time(time, _, _):
            time.isValid
        case let .date(date):
            true // FIXME: UT
        }
    }
}

/// Returns a position with explicitly associated tolerances.
///
/// - Parameters:
///   - time: The time to reach.
///   - toleranceBefore: The tolerance allowed before the time to reach.
///   - toleranceAfter: The tolerance allowed after the time to reach.
/// - Returns: A position.
///
/// Larger tolerances let the player seek to an approximate location more efficiently. Smaller tolerances may incur
/// additional decoding delay, possibly impacting seek performance.
public func to(_ time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) -> Position {
    .init(time: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter)
}

/// Returns a precise position.
///
/// - Parameter time: The time to reach.
/// - Returns: A position.
///
/// Precise positions may involve additional decoding delay, possibly impacting seek performance.
public func at(_ time: CMTime) -> Position {
    .init(time: time, toleranceBefore: .zero, toleranceAfter: .zero)
}

public func at(_ date: Date) -> Position {
    .init(date: date)
}

/// Returns an approximate position.
///
/// - Parameter time: The time to reach.
/// - Returns: A position.
public func near(_ time: CMTime) -> Position {
    .init(time: time, toleranceBefore: .positiveInfinity, toleranceAfter: .positiveInfinity)
}

/// Returns an approximate position always located before the specified time.
///
/// - Parameter time: The time to reach.
/// - Returns: A position.
public func before(_ time: CMTime) -> Position {
    .init(time: time, toleranceBefore: .positiveInfinity, toleranceAfter: .zero)
}

/// Returns an approximate position always located after the specified time.
/// 
/// - Parameter time: The time to reach.
/// - Returns: A position.
public func after(_ time: CMTime) -> Position {
    .init(time: time, toleranceBefore: .zero, toleranceAfter: .positiveInfinity)
}
