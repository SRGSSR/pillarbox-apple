//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import TimelaneCombine

extension AVPlayer {
    private static func timeRangePublisher(for item: AVPlayerItem, configuration: PlayerConfiguration) -> AnyPublisher<CMTimeRange, Never> {
        Publishers.CombineLatest3(
            item.publisher(for: \.loadedTimeRanges),
            item.publisher(for: \.seekableTimeRanges),
            item.publisher(for: \.duration)
        )
        .compactMap { loadedTimeRanges, seekableTimeRanges, duration in
            guard let firstRange = seekableTimeRanges.first?.timeRangeValue,
                  let lastRange = seekableTimeRanges.last?.timeRangeValue else {
                return !loadedTimeRanges.isEmpty ? .zero : nil
            }

            let timeRange = CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
            if duration.isIndefinite && CMTimeCompare(timeRange.duration, configuration.dvrThreshold) == -1 {
                return CMTimeRange(start: timeRange.start, duration: .zero)
            }
            else {
                return timeRange
            }
        }
        .eraseToAnyPublisher()
    }

    private static func bufferingPublisher(for item: AVPlayerItem) -> AnyPublisher<Bool, Never> {
        item.publisher(for: \.isPlaybackLikelyToKeepUp)
            .map { !$0 }
            .eraseToAnyPublisher()
    }

    private static func bufferEmptyPublisher(for item: AVPlayerItem) -> AnyPublisher<Bool, Never> {
        item.publisher(for: \.isPlaybackBufferEmpty)
            .eraseToAnyPublisher()
    }

    private static func bufferFullPublisher(for item: AVPlayerItem) -> AnyPublisher<Bool, Never> {
        item.publisher(for: \.isPlaybackBufferFull)
            .eraseToAnyPublisher()
    }

    func itemStatePublisher() -> AnyPublisher<ItemState, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { $0.itemStatePublisher() }
            .switchToLatest()
            .prepend(ItemState.itemState(for: currentItem))
            .removeDuplicates()
            .lane("player_item_state")
            .eraseToAnyPublisher()
    }

    func ratePublisher() -> AnyPublisher<Float, Never> {
        publisher(for: \.rate)
            .eraseToAnyPublisher()
    }

    func playbackStatePublisher() -> AnyPublisher<PlaybackState, Never> {
        Publishers.CombineLatest(
            itemStatePublisher(),
            ratePublisher()
        )
        .map { PlaybackState.state(for: $0, rate: $1) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func itemDurationPublisher() -> AnyPublisher<CMTime, Never> {
        publisher(for: \.currentItem?.duration)
            .replaceNil(with: .indefinite)
            .eraseToAnyPublisher()
    }

    func itemTimeRangePublisher(configuration: PlayerConfiguration) -> AnyPublisher<CMTimeRange, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { Self.timeRangePublisher(for: $0, configuration: configuration) }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func currentTimePublisher(interval: CMTime) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(for: self, interval: interval, queue: .global(qos: .userInteractive))
            .eraseToAnyPublisher()
    }

    func seekingPublisher() -> AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default.weakPublisher(for: .willSeek, object: self)
                .map { _ in true },
            NotificationCenter.default.weakPublisher(for: .didSeek, object: self)
                .map { _ in false }
        )
        .prepend(false)
        .eraseToAnyPublisher()
    }

    func pulsePublisher(configuration: PlayerConfiguration) -> AnyPublisher<Pulse?, Never> {
        Publishers.CombineLatest3(
            currentTimePublisher(interval: configuration.tick),
            itemTimeRangePublisher(configuration: configuration),
            itemDurationPublisher()
        )
        .compactMap { time, timeRange, itemDuration in
            Pulse(time: time, timeRange: timeRange, itemDuration: itemDuration)
        }
        .removeDuplicates(by: Pulse.close(within: CMTimeMultiplyByFloat64(configuration.tick, multiplier: 0.5)))
        .eraseToAnyPublisher()
    }

    func bufferingPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { Self.bufferingPublisher(for: $0) }
            .switchToLatest()
            .prepend(false)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func bufferEmptyPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { Self.bufferEmptyPublisher(for: $0) }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func bufferFullPublisher() -> AnyPublisher<Bool, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { Self.bufferFullPublisher(for: $0) }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
