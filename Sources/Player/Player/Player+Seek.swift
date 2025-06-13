//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import CoreMedia

public extension Player {
    /// Returns the optimal position to use when seeking to a given time, depending on the provided item.
    ///
    /// For an even better seek experience the position should be reached with the player paused during the seek
    /// operation.
    ///
    /// - Parameters:
    ///   - time: The time to reach.
    ///   - item: The item to consider.
    ///
    /// - Returns: The optimal position to use.
    private static func optimalPosition(reaching time: CMTime, for item: AVPlayerItem?) -> Position {
        // This implementation is based on analysis of `AVPlayerViewController` behavior during seeks for various
        // types of streams.
        guard let item else {
            return near(time)
        }
        // If the stream supports stepping use an exact position. This makes it possible for a paused player to provide a
        // frame-by-frame user experience.
        if item.canStepForward {
            return at(time)
        }
        // If the stream supports fast-forward use one-sided tolerance. This allows a paused player to rely on available
        // I-frame playlists to provide for a faster seeking user experience (trick mode).
        else if item.canPlayFastForward {
            return after(time)
        }
        // For standard streams just seek as fast as we can (but without additional benefits).
        else {
            return near(time)
        }
    }

    /// Checks whether seeking to a specific time is possible.
    ///
    /// - Parameter time: The time to seek to.
    /// - Returns: `true` if possible.
    func canSeek(to time: CMTime) -> Bool {
        guard seekableTimeRange.isValidAndNotEmpty else { return false }
        return seekableTimeRange.start <= time && time <= seekableTimeRange.end
    }

    /// Seeks to a given position.
    /// 
    /// - Parameters:
    ///   - position: The position to seek to.
    ///   - smooth: Set to `true` to enable smooth seeking. This allows any currently pending seek to complete before
    ///     any new seek is performed, preventing unnecessary cancellation and providing for a smoother experience.
    ///   - completion: A completion called when seeking ends. The provided Boolean informs whether the seek could
    ///     finish without being cancelled.
    func seek(
        _ position: Position,
        smooth: Bool = true,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        // Mitigates issues arising when seeking to the very end of the range by introducing a small offset.
        let time = position.time.clamped(to: seekableTimeRange, offset: CMTime(value: 1, timescale: 10))
        guard time.isValid else {
            completion(true)
            return
        }
        queuePlayer.seek(
            to: time,
            toleranceBefore: position.toleranceBefore,
            toleranceAfter: position.toleranceAfter,
            smooth: smooth,
            completionHandler: completion
        )
    }

    /// Performs an optimal seek to a given time, providing the best possible interactive user experience in all cases.
    ///
    /// - Parameters:
    ///   - time: The time to reach.
    ///   - completion: A completion called when seeking ends. The provided Boolean informs whether the seek could
    ///     finish without being cancelled.
    ///
    /// If a user interaction is causing this seek method to be called several times in a row, the player should be paused
    /// during the interaction to achieve the best possible result.
    func seek(to time: CMTime, completion: @escaping (Bool) -> Void = { _ in }) {
        let position = Self.optimalPosition(reaching: time, for: queuePlayer.currentItem)
        seek(position, smooth: true, completion: completion)
    }

    /// Requests that the player seek to a specified date, and to notify you when the seek is complete.
    ///
    /// - Parameters:
    ///   - date: The date to reach.
    ///   - completion: A completion called when seeking ends. The provided Boolean informs whether the seek could
    ///     finish without being cancelled.
    func seek(to date: Date, completion: @escaping (Bool) -> Void = { _ in }) {
        queuePlayer.seek(to: date, completionHandler: completion)
    }

    /// Performs a precise seek to a chapter.
    ///
    /// - Parameters:
    ///   - chapter: The chapter to reach.
    ///   - completion: A completion called when seeking ends. The provided Boolean informs whether the seek could
    ///     finish without being cancelled.
    func seek(to chapter: Chapter, completion: @escaping (Bool) -> Void = { _ in }) {
        seek(at(chapter.timeRange.start + CMTime(value: 1, timescale: 10)), completion: completion)
    }
}
