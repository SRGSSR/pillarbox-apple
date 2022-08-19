//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

public extension Player {
    struct Properties {
        public struct Playback {
            public let time: CMTime
            public let timeRange: CMTimeRange

            static var empty: Self {
                Playback(time: .zero, timeRange: .invalid)
            }
        }

        public let playback: Playback
        public let targetTime: CMTime?

        public var progress: Float {
            Time.progress(for: playback.time, in: playback.timeRange)
        }

        public var targetProgress: Float? {
            guard let targetTime else { return nil }
            return Time.progress(for: targetTime, in: playback.timeRange)
        }

        static func empty(for player: AVPlayer) -> Self {
            Properties(playback: .empty, targetTime: nil)
        }
    }
}
