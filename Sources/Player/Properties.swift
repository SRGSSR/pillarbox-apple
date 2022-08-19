//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

extension Player {
    public struct Properties {
        public struct Playback {
            public let time: CMTime
            public let timeRange: CMTimeRange

            static var empty: Self {
                Playback(time: .zero, timeRange: .invalid)
            }
        }

        public let itemState: ItemState
        public let rate: Float
        public let playback: Playback
        public let targetTime: CMTime?

        public var state: State {
            switch itemState {
            case .readyToPlay:
                return (rate == 0) ? .paused : .playing
            case let .failed(error: error):
                return .failed(error: error)
            case .ended:
                return .ended
            case .unknown:
                return .idle
            }
        }

        public var progress: Float {
            Time.progress(for: playback.time, in: playback.timeRange)
        }

        public var targetProgress: Float? {
            guard let targetTime else { return nil }
            return Time.progress(for: targetTime, in: playback.timeRange)
        }

        static func empty(for player: AVPlayer) -> Self {
            Properties(
                itemState: .unknown,
                rate: player.rate,
                playback: .empty,
                targetTime: nil
            )
        }
    }
}
