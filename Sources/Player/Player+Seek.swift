//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public extension Player {
    /// Returns the optimal position to reach a given time based on available item information.
    ///
    /// For perfect results the position should be reached with the player paused during the seek operation.
    ///
    /// - Parameters:
    ///   - time: The time to reach.
    ///   - item: The item to consider.
    ///
    /// - Returns: An optimal position to seek to.
    private static func optimalPosition(reaching time: CMTime, for item: AVPlayerItem?) -> Position {
        // Based on analysis of `AVPlayerViewController` behavior during seeks for a variety of content.
        guard let item else {
            return near(time)
        }
        if item.canStepForward {
            return at(time)
        }
        else if item.canPlayFastForward {
            return after(time)
        }
        else {
            return near(time)
        }
    }

    /// Checks whether seeking to a specific time is possible.
    ///
    /// - Parameter time: The time to seek to.
    /// - Returns: `true` if possible.
    func canSeek(to time: CMTime) -> Bool {
        guard timeRange.isValidAndNotEmpty else { return false }
        return timeRange.start <= time && time <= timeRange.end
    }

    /// Seeks to a given position.
    /// 
    /// - Parameters:
    ///   - position: The position to seek to.
    ///   - smooth: Set to `true` to enable smooth seeking. This allows any currently pending seek to complete before
    ///     any new seek is performed, preventing unnecessary cancellation. This makes it possible for the playhead
    ///     position to be moved in a smoother way.
    ///   - paused: Set to `true` to pause playback during seeks. This in general allows the player to seek more
    ///     efficiently.
    ///   - completion: A completion called when seeking ends. The provided Boolean informs
    ///     whether the seek could finish without being cancelled.
    func seek(
        _ position: Position,
        smooth: Bool = true,
        paused: Bool = true,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        // Mitigates issues arising when seeking to the very end of the range by introducing a small offset.
        let time = position.time.clamped(to: timeRange, offset: CMTime(value: 1, timescale: 10))
        guard time.isValid else {
            completion(true)
            return
        }
        queuePlayer.seek(
            to: time,
            toleranceBefore: position.toleranceBefore,
            toleranceAfter: position.toleranceAfter,
            smooth: smooth,
            paused: paused,
            completionHandler: completion
        )
    }

    /// Performs an optimal seek to a given time, providing the smoothest possible experience depending on the type of
    /// content.
    ///
    /// - Parameters:
    ///   - time: The time to reach.
    ///   - completion: A completion called when seeking ends. The provided Boolean informs
    ///     whether the seek could finish without being cancelled.
    func optimalSeek(to time: CMTime, completion: @escaping (Bool) -> Void = { _ in }) {
        let position = Self.optimalPosition(reaching: time, for: queuePlayer.currentItem)
        seek(position, smooth: true, paused: true, completion: completion)
    }
}
