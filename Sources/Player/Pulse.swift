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

    private static let tolerance: Int64 = 1

    init?(time: CMTime, timeRange: CMTimeRange) {
        guard time.isNumeric, timeRange.isValid else { return nil }
        self.time = time
        self.timeRange = timeRange
    }

    var progress: Float {
        progress(for: time)
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

    static func publisher(for player: AVPlayer, queue: DispatchQueue) -> AnyPublisher<Pulse?, Never> {
        // TODO: Maybe better criterium than item state (asset duration? Maybe more resilient for AirPlay)
        Publishers.Merge(
            ItemState.publisher(for: player)
                .filter { $0 == .readyToPlay }
                .map { _ in .zero },
            Publishers.PeriodicTimePublisher(for: player, interval: CMTimeMake(value: tolerance, timescale: 1), queue: queue)
        )
        .compactMap { [weak player] time in
            guard let player, let timeRange = Time.timeRange(for: player.currentItem) else { return nil }
            return Pulse(time: time, timeRange: timeRange)
        }
        .removeDuplicates(by: close(within: Double(tolerance) / 2))
        .eraseToAnyPublisher()
    }

    private static func close(within tolerance: TimeInterval) -> ((Pulse?, Pulse?) -> Bool) {
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
            }
        }
    }
}
