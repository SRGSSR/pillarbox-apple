//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import MediaPlayer

extension QueuePlayer {
    func contextPublisher() -> AnyPublisher<QueuePlayerContext, Never> {
        Publishers.CombineLatest(
            currentItemContextPublisher(),
            publisher(for: \.rate)
        )
        .map { .init(currentItemContext: $0, rate: $1) }
        .eraseToAnyPublisher()
    }

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
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    /// Publishes the current time, smoothing out emitted values during seeks.
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
            publisher(for: \.rate),
            seekTimePublisher()
        )
        .map { [weak self] properties, rate, seekTime in
            var nowPlayingInfo = NowPlaying.Info()
            if let properties {
                let isLive = StreamType(for: properties.timeRange, itemDuration: properties.itemDuration) == .live
                nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = isLive
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = properties.isBuffering ? 0 : rate
                if let time = seekTime ?? self?.currentTime(), time.isValid {
                    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = (time - properties.timeRange.start).seconds
                }
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = properties.timeRange.duration.seconds
            }
            return nowPlayingInfo
        }
        .eraseToAnyPublisher()
    }

    private func currentItemContextPublisher() -> AnyPublisher<AVPlayerItemContext, Never> {
        publisher(for: \.currentItem)
            .map { item in
                guard let item else {
                    return Just(AVPlayerItemContext.empty).eraseToAnyPublisher()
                }
                return item.contextPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
