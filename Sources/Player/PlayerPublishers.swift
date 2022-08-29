//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine

// TODO: Other ideas for publishers
//        - Boundary time publisher
//        - Asset property publisher (can register to one or several properties and have them published; implemented
//          internally with modern async API). Might be useful as signal for the Pulse publisher.

extension AVPlayer {
    private static func timeRangePublisher(for item: AVPlayerItem) -> AnyPublisher<CMTimeRange, Never> {
        Publishers.CombineLatest(
            item.publisher(for: \.loadedTimeRanges),
            item.publisher(for: \.seekableTimeRanges)
        )
        .compactMap { loadedTimeRanges, seekableTimeRanges in
            guard let firstRange = seekableTimeRanges.first?.timeRangeValue,
                  let lastRange = seekableTimeRanges.last?.timeRangeValue else {
                return !loadedTimeRanges.isEmpty ? .zero : nil
            }
            return CMTimeRangeFromTimeToTime(start: firstRange.start, end: lastRange.end)
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

    func itemTimeRangePublisher() -> AnyPublisher<CMTimeRange, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { Self.timeRangePublisher(for: $0) }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func currentTimePublisher(interval: CMTime, queue: DispatchQueue) -> AnyPublisher<CMTime, Never> {
        Publishers.Merge(
            // TODO: Maybe better criterium than item state (asset duration? Maybe more resilient for AirPlay)
            itemStatePublisher()
                .filter { $0 == .readyToPlay }
                .map { _ in .zero },
            Publishers.PeriodicTimePublisher(for: self, interval: interval, queue: queue)
        )
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

    func pulsePublisher(interval: CMTime, queue: DispatchQueue) -> AnyPublisher<Pulse?, Never> {
        Publishers.CombineLatest3(
            currentTimePublisher(interval: interval, queue: queue),
            itemTimeRangePublisher(),
            itemDurationPublisher()
        )
        .compactMap { time, timeRange, itemDuration in
            Pulse(time: time, timeRange: timeRange, itemDuration: itemDuration)
        }
        .removeDuplicates(by: Pulse.close(within: CMTimeGetSeconds(interval) / 2))
        .eraseToAnyPublisher()
    }

    func playbackPropertiesPublisher(interval: CMTime) -> AnyPublisher<PlaybackProperties, Never> {
        Publishers.CombineLatest(
            pulsePublisher(interval: interval, queue: DispatchQueue(label: "ch.srgssr.pillarbox.player")),
            seekTargetTimePublisher()
        )
        .map { PlaybackProperties(pulse: $0, targetTime: $1) }
        .removeDuplicates(by: PlaybackProperties.close(within: CMTimeGetSeconds(interval) / 2))
        .eraseToAnyPublisher()
    }
}
