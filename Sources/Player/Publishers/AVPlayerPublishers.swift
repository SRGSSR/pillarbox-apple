//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core
import TimelaneCombine

extension AVPlayer {
    func currentItemStatePublisher() -> AnyPublisher<ItemState, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0 }
            .map { $0.itemStatePublisher() }
            .switchToLatest()
            .prepend(ItemState(for: currentItem))
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

    /// Returns a publisher emitting values for the current item duration.
    ///
    /// Unlike `AVPlayerItem` this publisher returns `.invalid` when the duration is unknown. Note that `.indefinite`
    /// is a valid duration for DVR streams.
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

    func currentItemBufferPublisher() -> AnyPublisher<Float, Never> {
        publisher(for: \.currentItem)
            .map { item -> AnyPublisher<Float, Never> in
                guard let item else { return Just(0).eraseToAnyPublisher() }
                return Publishers.CombineLatest(
                    item.loadedTimeRangePublisher(),
                    item.durationPublisher()
                )
                .map { loadedTimeRange, duration in
                    guard loadedTimeRange.end.isNumeric, duration.isNumeric, duration != .zero else { return 0 }
                    return Float(loadedTimeRange.end.seconds / duration.seconds)
                }
                .eraseToAnyPublisher()
            }
            .switchToLatest()
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

    // swiftlint:disable:next cyclomatic_complexity
    func smoothCurrentItemPublisher() -> AnyPublisher<CurrentItem, Never> {
        publisher(for: \.currentItem)
            .withPrevious()
            .map { previousItem, currentItem in
                if let currentItem {
                    switch ItemState(for: currentItem) {
                    case .failed:
                        return .bad(currentItem)
                    default:
                        return .good(currentItem)
                    }
                }
                else if let previousItem {
                    switch ItemState(for: previousItem) {
                    case .failed:
                        return .bad(previousItem)
                    default:
                        return .good(currentItem)
                    }
                }
                else {
                    return .good(currentItem)
                }
            }
            .eraseToAnyPublisher()
    }

    func presentationSizePublisher() -> AnyPublisher<CGSize?, Never> {
        Publishers.CombineLatest(
            publisher(for: \.currentItem),
            publisher(for: \.isExternalPlaybackActive)
        )
        .map { currentItem, isExternalPlaybackActive -> AnyPublisher<CGSize?, Never> in
            guard !isExternalPlaybackActive else {
                return Empty().eraseToAnyPublisher()
            }
            guard let currentItem else {
                return Just(nil).eraseToAnyPublisher()
            }
            return currentItem.presentationSizePublisher()
        }
        .switchToLatest()
        .removeDuplicates()
        .eraseToAnyPublisher()
    }
}
