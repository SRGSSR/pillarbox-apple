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
        Publishers.CombineLatest5(
            currentItemContextPublisher(),
            publisher(for: \.rate),
            isSeekingPublisher(),
            publisher(for: \.isExternalPlaybackActive),
            publisher(for: \.isMuted)
        )
        .map { .init(currentItemContext: $0, rate: $1, isSeeking: $2, isExternalPlaybackActive: $3, isMuted: $4) }
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

    private func currentItemContextPublisher() -> AnyPublisher<AVPlayerItemContext, Never> {
        publisher(for: \.currentItem)
            .map { item in
                guard let item else { return Just(AVPlayerItemContext.empty).eraseToAnyPublisher() }
                return item.contextPublisher()
            }
            .switchToLatest()
            .prepend(.empty)
            .eraseToAnyPublisher()
    }
}

extension QueuePlayer {
    func errorPublisher() -> AnyPublisher<Error?, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0?.errorPublisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

extension QueuePlayer {
    func timeContextPublisher() -> AnyPublisher<TimeContext, Never> {
        publisher(for: \.currentItem)
            .map { item in
                guard let item else { return Just(TimeContext.empty).eraseToAnyPublisher() }
                return item.timeContextPublisher().eraseToAnyPublisher()
            }
            .switchToLatest()
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

    func nowPlayingInfoPlaybackPublisher() -> AnyPublisher<NowPlaying.Info, Never> {
        Publishers.CombineLatest3(
            contextPublisher(),
            timeContextPublisher(),
            seekTimePublisher()
        )
        .map { [weak self] context, timeContext, seekTime in
            var nowPlayingInfo = NowPlaying.Info()
            let streamType = StreamType(for: timeContext.timeRange, itemDuration: context.currentItemContext.duration)
            if streamType != .unknown {
                nowPlayingInfo[MPNowPlayingInfoPropertyIsLiveStream] = (streamType == .live)
                nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = context.currentItemContext.isBuffering ? 0 : context.rate
                if let time = seekTime ?? self?.currentTime(), time.isValid {
                    nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = (time - timeContext.timeRange.start).seconds
                }
                nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = timeContext.timeRange.duration.seconds
            }
            return nowPlayingInfo
        }
        .eraseToAnyPublisher()
    }
}
