//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

/// A description for a position to reach.
public struct Position {
    /// The time to reach.
    public let time: CMTime

    /// The tolerance allowed before the time to reach.
    public let toleranceBefore: CMTime

    /// The tolerance allowed after the time to reach.
    public let toleranceAfter: CMTime

    fileprivate init(time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime) {
        self.time = time
        self.toleranceBefore = toleranceBefore
        self.toleranceAfter = toleranceAfter
    }

    func after(_ timeRanges: [CMTimeRange]) -> Self? {
        guard let fixedTime = time.after(timeRanges: timeRanges) else { return nil }
        return .init(time: fixedTime, toleranceBefore: .zero, toleranceAfter: toleranceAfter)
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
