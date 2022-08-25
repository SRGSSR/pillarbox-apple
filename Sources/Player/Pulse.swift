//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import CoreMedia

/// Player pulse.
public struct Pulse {
    /// The current time.
    public let time: CMTime
    /// The time range.
    public let timeRange: CMTimeRange

    static var empty: Self {
        Pulse(time: .zero, timeRange: .invalid)
    }

    var progress: Float {
        return progress(for: time)
    }

    func progress(for time: CMTime) -> Float {
        guard time.isNumeric && timeRange.isValid && !timeRange.isEmpty else { return 0 }
        let elapsedTime = CMTimeGetSeconds(CMTimeSubtract(time, timeRange.start))
        let duration = CMTimeGetSeconds(timeRange.duration)
        return Float(elapsedTime / duration).clamped(to: 0...1)
    }

    func time(forProgress progress: Float) throws -> CMTime {
        let multiplier = Float64(progress.clamped(to: 0...1))
        return CMTimeAdd(timeRange.start, CMTimeMultiplyByFloat64(timeRange.duration, multiplier: multiplier))
    }

    static func publisher(for player: AVPlayer, queue: DispatchQueue) -> AnyPublisher<Pulse, Never> {
        Publishers.PeriodicTimePublisher(for: player, interval: CMTimeMake(value: 1, timescale: 1), queue: queue)
            .map { [weak player] time in
                guard let player else { return .empty }
                return Pulse(time: time, timeRange: Time.timeRange(for: player.currentItem))
            }
            .eraseToAnyPublisher()
    }
}
