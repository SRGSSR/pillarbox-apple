//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

/// Stream types.
public enum StreamType {
    /// Not yet determined.
    case unknown
    /// On-demand stream.
    case onDemand
    /// Livestream without DVR.
    case live
    /// Livestream with DVR.
    case dvr
}

public extension Player {
    /// Player properties.
    struct Properties {
        /// Playback information.
        public struct Playback {
            /// The current time.
            public let time: CMTime
            /// The time range.
            public let timeRange: CMTimeRange

            static var empty: Self {
                Playback(time: .zero, timeRange: .invalid)
            }

            func time(forProgress progress: Float) -> CMTime {
                let multiplier = Float64(progress.clamped(to: 0...1))
                return CMTimeAdd(timeRange.start, CMTimeMultiplyByFloat64(timeRange.duration, multiplier: multiplier))
            }
        }

        /// Playback information.
        public let playback: Playback
        /// Time targeted by a pending seek, if any.
        public let targetTime: CMTime?

        /// A value in 0...1 describing the current playback progress.
        public var progress: Float {
            Time.progress(for: playback.time, in: playback.timeRange)
        }

        /// The stream type.
        public var streamType: StreamType {
            let timeRange = playback.timeRange
            guard timeRange.isValid else { return .unknown }
            return .onDemand
        }

        /// A value in 0...1 describing the playback progress targeted by a pending seek, if any.
        public var targetProgress: Float? {
            guard let targetTime else { return nil }
            return Time.progress(for: targetTime, in: playback.timeRange)
        }

        static func empty(for player: AVPlayer) -> Self {
            Properties(playback: .empty, targetTime: nil)
        }
    }

    static func propertiesPublisher(for player: AVPlayer) -> AnyPublisher<Properties, Never> {
        Publishers.CombineLatest(
            playbackPublisher(for: player, queue: DispatchQueue(label: "ch.srgssr.pillarbox.player")),
            seekTargetTimePublisher(for: player)
        )
        .map { Properties(playback: $0, targetTime: $1) }
        .eraseToAnyPublisher()
    }

    static func playbackPublisher(for player: AVPlayer, queue: DispatchQueue) -> AnyPublisher<Properties.Playback, Never> {
        periodicTimePublisher(for: player, interval: CMTimeMake(value: 1, timescale: 1), queue: queue)
            .map { [weak player] time in
                Properties.Playback(
                    time: time,
                    timeRange: Time.timeRange(for: player?.currentItem)
                )
            }
            .eraseToAnyPublisher()
    }

    static func seekTargetTimePublisher(for player: AVPlayer) -> AnyPublisher<CMTime?, Never> {
        Publishers.Merge(
            NotificationCenter.default.weakPublisher(for: .willSeek, object: player)
                .map { $0.userInfo?[SystemPlayer.SeekInfoKey.targetTime] as? CMTime },
            NotificationCenter.default.weakPublisher(for: .didSeek, object: player)
                .map { _ in nil }
        )
        .prepend(nil)
        .eraseToAnyPublisher()
    }
}
