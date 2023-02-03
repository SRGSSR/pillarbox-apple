//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import MediaPlayer

extension QueuePlayer {
    func seekingPublisher() -> AnyPublisher<Bool, Never> {
        Publishers.Merge(
            Self.notificationCenter.weakPublisher(for: .willSeek, object: self)
                .map { _ in true },
            Self.notificationCenter.weakPublisher(for: .didSeek, object: self)
                .map { _ in false }
        )
        .prepend(false)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func seekTimePublisher() -> AnyPublisher<CMTime?, Never> {
        let notificationCenter = Self.notificationCenter
        return Publishers.Merge(
            notificationCenter.weakPublisher(for: .willSeek, object: self)
                .map { notification in
                    notification.userInfo?[SeekKey.time] as? CMTime
                },
            notificationCenter.weakPublisher(for: .didSeek, object: self)
                .map { _ in nil }
        )
        .prepend(nil)
        .eraseToAnyPublisher()
    }

    /// Publishes current time, taking into account seeks to smooth out emitted values.
    func smoothCurrentTimePublisher(interval: CMTime, queue: DispatchQueue) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest(
            Publishers.PeriodicTimePublisher(for: self, interval: interval, queue: queue),
            seekTimePublisher()
        )
        .map { time, seekTime in
            seekTime ?? time
        }
        .eraseToAnyPublisher()
    }

    func nowPlayingInfoPlaybackPublisher() -> AnyPublisher<NowPlaying.Info, Never> {
        Publishers.CombineLatest3(
            nowPlayingInfoPropertiesPublisher(),
            smoothCurrentTimePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main),
            publisher(for: \.rate)
        )
        .map { properties, time, rate in
            var nowPlayingInfo = NowPlaying.Info()
            if let properties {
                let isLive = StreamType(for: properties.timeRange, itemDuration: properties.itemDuration) == .live
                nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = isLive
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = properties.isBuffering ? 0 : rate
                if time.isValid {
                    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = (time - properties.timeRange.start).seconds
                }
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = properties.timeRange.duration.seconds
            }
            return nowPlayingInfo
        }
        .eraseToAnyPublisher()
    }
}
