//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

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

        public var streamType: StreamType {
            .unknown
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
}
