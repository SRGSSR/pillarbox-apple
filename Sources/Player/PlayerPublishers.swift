//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import MediaPlayer
import TimelaneCombine

extension AVPlayer {
    func currentItemStatePublisher() -> AnyPublisher<ItemState, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { $0.itemStatePublisher() }
            .switchToLatest()
            .prepend(ItemState.itemState(for: currentItem))
            .removeDuplicates()
            .lane("player_item_state")
            .eraseToAnyPublisher()
    }

    func playbackStatePublisher() -> AnyPublisher<PlaybackState, Never> {
        Publishers.CombineLatest(
            currentItemStatePublisher(),
            publisher(for: \.rate)
        )
        .map { PlaybackState.state(for: $0, rate: $1) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    /// A publisher returning current item duration. Unlike `AVPlayerItem` this publisher returns `.invalid` when
    /// the duration is unknown (`.indefinite` is still a valid value for DVR streams).
    func currentItemDurationPublisher() -> AnyPublisher<CMTime, Never> {
        publisher(for: \.currentItem)
            .map { item -> AnyPublisher<CMTime, Never> in
                guard let item else {
                    return Just(.invalid).eraseToAnyPublisher()
                }
                return item.durationPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func currentItemTimeRangePublisher() -> AnyPublisher<CMTimeRange, Never> {
        publisher(for: \.currentItem)
            .map { item in
                guard let item else { return Just(CMTimeRange.invalid).eraseToAnyPublisher() }
                return item.timeRangePublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func seekingPublisher() -> AnyPublisher<Bool, Never> {
        Publishers.Merge(
            QueuePlayer.notificationCenter.weakPublisher(for: .willSeek, object: self)
                .map { _ in true },
            QueuePlayer.notificationCenter.weakPublisher(for: .didSeek, object: self)
                .map { _ in false }
        )
        .prepend(false)
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func bufferingPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0?.bufferingPublisher() }
            .switchToLatest()
            .prepend(false)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func chunkDurationPublisher() -> AnyPublisher<CMTime, Never> {
        publisher(for: \.currentItem)
            .map { item -> AnyPublisher<CMTime, Never> in
                guard let item else { return Just(.invalid).eraseToAnyPublisher() }
                return item.asset.propertyPublisher(.minimumTimeOffsetFromLive)
                    .map { CMTimeMultiplyByRatio($0, multiplier: 1, divisor: 3) }       // The minimum offset represents 3 chunks
                    .replaceError(with: .invalid)
                    .prepend(.invalid)
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func nowPlayingInfoPropertiesPublisher() -> AnyPublisher<NowPlaying.Properties?, Never> {
        publisher(for: \.currentItem)
            .map { item -> AnyPublisher<NowPlaying.Properties?, Never> in
                guard let item else { return Just(nil).eraseToAnyPublisher() }
                return item.nowPlayingInfoPropertiesPublisher()
                    .map { Optional($0) }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }

    func seekTimePublisher() -> AnyPublisher<CMTime?, Never> {
        let notificationCenter = QueuePlayer.notificationCenter
        return Publishers.Merge(
            notificationCenter.weakPublisher(for: .willSeek, object: self)
                .map { notification in
                    notification.userInfo?[SeekKey.time] as? CMTime
                },
            notificationCenter.weakPublisher(for: .didSeek, object: self)
                .map { notification in
                    Just(notification.userInfo?[SeekKey.time] as? CMTime)
                        .append(nil)
                }
                .switchToLatest()
        )
        .prepend(nil)
        .eraseToAnyPublisher()
    }

    func nowPlayingInfoCurrentTimePublisher(interval: CMTime, queue: DispatchQueue) -> AnyPublisher<CMTime, Never> {
        Publishers.CombineLatest(
            Publishers.PeriodicTimePublisher(for: self, interval: interval, queue: queue),
            seekTimePublisher()
        )
        .map { time, seekTime in
            return seekTime ?? time
        }
        .eraseToAnyPublisher()
    }

    func nowPlayingInfoPlaybackPublisher() -> AnyPublisher<NowPlaying.Info, Never> {
        Publishers.CombineLatest(
            nowPlayingInfoPropertiesPublisher(),
            nowPlayingInfoCurrentTimePublisher(interval: CMTime(value: 1, timescale: 1), queue: .main)
        )
        .map { properties, time in
            var nowPlayingInfo = NowPlaying.Info()
            if let properties {
                let isLive = StreamType(for: properties.timeRange, itemDuration: properties.itemDuration) == .live
                nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = isLive
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = properties.isBuffering ? 0 : 1
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
