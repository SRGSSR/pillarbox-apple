//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension Player {
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
    ///   - completion: A completion called when seeking ends. The provided Boolean informs
    ///     whether the seek could finish without being cancelled.
    func seek(
        _ position: Position,
        smooth: Bool = true,
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
            completionHandler: completion
        )
    }
}
