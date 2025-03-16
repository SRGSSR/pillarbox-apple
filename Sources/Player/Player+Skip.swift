//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import CoreMedia

public extension Player {
    /// Checks whether skipping backward is possible.
    ///
    /// - Returns: `true` if possible.
    func canSkipBackward() -> Bool {
        seekableTimeRange.isValidAndNotEmpty
    }

    /// Checks whether skipping forward is possible.
    ///
    /// - Returns: `true` if possible.
    func canSkipForward() -> Bool {
        guard seekableTimeRange.isValidAndNotEmpty else { return false }
        if duration.isIndefinite {
            let currentTime = queuePlayer.targetSeekTime ?? time()
            return canSeek(to: currentTime + forwardSkipTime)
        }
        else {
            return true
        }
    }

    /// Checks whether skipping in some direction is possible.
    ///
    /// - Returns: `true` if possible.
    func canSkip(_ skip: Skip) -> Bool {
        switch skip {
        case .backward:
            return canSkipBackward()
        case .forward:
            return canSkipForward()
        }
    }

    /// Skips backward.
    ///
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs whether the skip
    ///   could finish without being cancelled.
    func skipBackward(completion: @escaping (Bool) -> Void = { _ in }) {
        skip(withInterval: backwardSkipTime, toleranceBefore: .positiveInfinity, toleranceAfter: .zero, completion: completion)
    }

    /// Skips forward.
    /// 
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs whether the skip
    ///   could finish without being cancelled.
    func skipForward(completion: @escaping (Bool) -> Void = { _ in }) {
        skip(withInterval: forwardSkipTime, toleranceBefore: .zero, toleranceAfter: .positiveInfinity, completion: completion)
    }

    /// Skips in a given direction.
    ///
    /// - Parameter completion: A completion called when skipping ends. The provided Boolean informs whether the skip
    ///   could finish without being cancelled.
    func skip(_ skip: Skip, completion: @escaping (Bool) -> Void = { _ in }) {
        switch skip {
        case .backward:
            skipBackward(completion: completion)
        case .forward:
            skipForward(completion: completion)
        }
    }
}

extension Player {
    var backwardSkipTime: CMTime {
        CMTime(seconds: -configuration.backwardSkipInterval, preferredTimescale: 1)
    }

    var forwardSkipTime: CMTime {
        CMTime(seconds: configuration.forwardSkipInterval, preferredTimescale: 1)
    }
}

private extension Player {
    func skip(
        withInterval interval: CMTime,
        toleranceBefore: CMTime,
        toleranceAfter: CMTime,
        completion: @escaping (Bool) -> Void = { _ in }
    ) {
        assert(interval != .zero)
        let endTolerance = CMTime(value: 1, timescale: 1)
        let currentTime = queuePlayer.targetSeekTime ?? time()
        if interval < .zero || currentTime < seekableTimeRange.end - endTolerance {
            seek(
                to(currentTime + interval, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter),
                smooth: false,
                completion: completion
            )
        }
        else {
            completion(true)
        }
    }
}
