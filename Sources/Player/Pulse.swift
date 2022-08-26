//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CoreMedia

/// Player pulse.
struct Pulse {
    /// The current time. Guaranteed to be numeric.
    let time: CMTime
    /// The time range. Guaranteed to be valid.
    let timeRange: CMTimeRange
    /// Item duration.
    let itemDuration: CMTime

    var progress: Float {
        progress(for: time)
    }

    init?(time: CMTime, timeRange: CMTimeRange, itemDuration: CMTime) {
        guard time.isNumeric, timeRange.isValid else { return nil }
        self.time = time
        self.timeRange = timeRange
        self.itemDuration = itemDuration
    }

    static func publisher(for player: AVPlayer, interval: CMTime, queue: DispatchQueue) -> AnyPublisher<Pulse?, Never> {
        // TODO: Maybe better criterium than item state (asset duration? Maybe more resilient for AirPlay). Extract
        //       timeRange by KVObserving loaded and seekable time ranges.
        Publishers.CombineLatest(
            AVPlayer.currentTimePublisher(for: player, interval: interval, queue: queue),
            AVPlayer.itemDurationPublisher(for: player)
        )
        .compactMap { [weak player] time, itemDuration in
            guard let player, let timeRange = Time.timeRange(for: player.currentItem) else { return nil }
            return Pulse(time: time, timeRange: timeRange, itemDuration: itemDuration)
        }
        .removeDuplicates(by: close(within: CMTimeGetSeconds(interval) / 2))
        .eraseToAnyPublisher()
    }

    // TODO: Create a timePublisher for the current time and a timeRange publisher for the time range. Maybe on
    //       an AVPlayer category. TDD them and assemble them above. Maybe collect all publishers (playback time,
    //       boundary time, asset properties) on this AVPlayer category.
    static func close(within tolerance: TimeInterval) -> ((Pulse?, Pulse?) -> Bool) {
        precondition(tolerance >= 0)
        return { pulse1, pulse2 in
            switch (pulse1, pulse2) {
            case (.none, .none):
                return true
            case (.none, .some), (.some, .none):
                return false
            case let (.some(pulse1), .some(pulse2)):
                return Time.close(within: tolerance)(pulse1.time, pulse2.time)
                    && TimeRange.close(within: tolerance)(pulse1.timeRange, pulse2.timeRange)
                    && Time.close(within: tolerance)(pulse1.itemDuration, pulse2.itemDuration)
            }
        }
    }

    func progress(for time: CMTime) -> Float {
        guard time.isNumeric && timeRange.isValid && !timeRange.isEmpty else { return 0 }
        let elapsedTime = CMTimeGetSeconds(CMTimeSubtract(time, timeRange.start))
        let duration = CMTimeGetSeconds(timeRange.duration)
        return Float(elapsedTime / duration).clamped(to: 0...1)
    }

    func time(forProgress progress: Float) -> CMTime? {
        guard timeRange.isValid && !timeRange.isEmpty else { return nil }
        let multiplier = Float64(progress.clamped(to: 0...1))
        return CMTimeAdd(timeRange.start, CMTimeMultiplyByFloat64(timeRange.duration, multiplier: multiplier))
    }
}
