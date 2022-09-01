//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

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

    func itemStatePublisher() -> AnyPublisher<ItemState, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { $0.itemStatePublisher() }
            .switchToLatest()
            .prepend(ItemState.itemState(for: currentItem))
            .removeDuplicates()
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

    func currentTimePublisher(interval: CMTime, queue: DispatchQueue) -> AnyPublisher<CMTime, Never> {
        Publishers.PeriodicTimePublisher(for: self, interval: interval, queue: queue)
            .eraseToAnyPublisher()
    }

    func seekTargetTimePublisher() -> AnyPublisher<CMTime?, Never> {
        Publishers.Merge(
            NotificationCenter.default.weakPublisher(for: .willSeek, object: self)
                .map { $0.userInfo?[DequeuePlayer.SeekInfoKey.targetTime] as? CMTime },
            NotificationCenter.default.weakPublisher(for: .didSeek, object: self)
                .map { _ in nil }
        )
        .prepend(nil)
        .eraseToAnyPublisher()
    }

    func pulsePublisher(configuration: PlayerConfiguration, queue: DispatchQueue) -> AnyPublisher<Pulse?, Never> {
        Publishers.CombineLatest3(
            currentTimePublisher(interval: configuration.tick, queue: queue),
            itemTimeRangePublisher(configuration: configuration),
            itemDurationPublisher()
        )
        .compactMap { time, timeRange, itemDuration in
            Pulse(time: time, timeRange: timeRange, itemDuration: itemDuration)
        }
        .removeDuplicates(by: Pulse.close(within: CMTimeMultiplyByFloat64(configuration.tick, multiplier: 0.5)))
        .eraseToAnyPublisher()
    }

    func playbackPropertiesPublisher(configuration: PlayerConfiguration) -> AnyPublisher<PlaybackProperties, Never> {
        Publishers.CombineLatest(
            pulsePublisher(configuration: configuration, queue: DispatchQueue(label: "ch.srgssr.pillarbox.player")),
            seekTargetTimePublisher()
        )
        .map { PlaybackProperties(pulse: $0, targetTime: $1) }
        .removeDuplicates(by: PlaybackProperties.close(within: CMTimeMultiplyByFloat64(configuration.tick, multiplier: 0.5)))
        .eraseToAnyPublisher()
    }
}
