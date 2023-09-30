//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import MediaPlayer

extension QueuePlayer {
    func propertiesPublisher() -> AnyPublisher<PlayerProperties, Never> {
        Publishers.CombineLatest5(
            itemPropertiesPublisher(),
            publisher(for: \.rate),
            isSeekingPublisher(),
            publisher(for: \.isExternalPlaybackActive),
            publisher(for: \.isMuted)
        )
        .map { .init(itemProperties: $0, rate: $1, isSeeking: $2, isExternalPlaybackActive: $3, isMuted: $4) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func isSeekingPublisher() -> AnyPublisher<Bool, Never> {
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
}

extension QueuePlayer {
    /// Publishes the current time, smoothing out emitted values during seeks.
    func smoothCurrentTimePublisher(interval: CMTime, queue: DispatchQueue) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest(
            seekTimePublisher(),
            Publishers.PeriodicTimePublisher(for: self, interval: interval, queue: queue)
        )
        .map { $0 ?? $1 }
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

    func nowPlayingInfoPlaybackPublisher() -> AnyPublisher<NowPlayingInfo, Never> {
        Publishers.CombineLatest(
            propertiesPublisher(),
            seekTimePublisher()
        )
        .map { [weak self] properties, seekTime in
            var nowPlayingInfo = NowPlayingInfo()
            let timeProperties = properties.itemProperties.timeProperties
            let streamType = StreamType(for: timeProperties.seekableTimeRange, itemDuration: properties.itemProperties.duration)
            if streamType != .unknown {
                nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = (streamType == .live)
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = properties.isBuffering ? 0 : properties.rate
                if let time = seekTime ?? self?.currentTime(), time.isValid {
                    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = (time - timeProperties.seekableTimeRange.start).seconds
                }
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = timeProperties.seekableTimeRange.duration.seconds
            }
            return nowPlayingInfo
        }
        .eraseToAnyPublisher()
    }
}
