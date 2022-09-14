//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import TimelaneCombine

extension AVPlayer {
    // TODO: Move these item-related methods to existing `AVPlayerItem` extension
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
            .map { item in
                Publishers.CombineLatest(
                    item.publisher(for: \.isPlaybackLikelyToKeepUp),
                    item.itemStatePublisher()
                )
                .map { isPlaybackLikelyToKeepUp, itemState in
                    switch itemState {
                    case .failed:
                        return false
                    default:
                        return !isPlaybackLikelyToKeepUp
                    }
                }
            }
            .switchToLatest()
            .prepend(false)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func bufferEmptyPublisher() -> AnyPublisher<Bool, Never> {
        // TODO: Observe \.currentItem?.isPlaybackBufferEmpty directly
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { $0.publisher(for: \.isPlaybackBufferEmpty) }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func bufferFullPublisher() -> AnyPublisher<Bool, Never> {
        // TODO: Observe \.currentItem?.isPlaybackBufferFull directly
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { $0.publisher(for: \.isPlaybackBufferFull) }
            .switchToLatest()
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
