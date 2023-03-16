//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import Core
import TimelaneCombine

enum ItemResult: Equatable {
    case finished(AVPlayerItem?)
    case failed(AVPlayerItem?)
}

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

    func smoothCurrentItemPublisher() -> AnyPublisher<ItemResult, Never> {
        publisher(for: \.currentItem)
            .withPrevious()
            .map { previousItem, currentItem in
                if let currentItem {
                    return .finished(currentItem)
                }
                else if let previousItem {
                    switch ItemState(for: previousItem) {
                    case .failed:
                        return .failed(previousItem)
                    default:
                        return .finished(currentItem)
                    }
                }
                else {
                    return .finished(currentItem)
                }
            }
            .eraseToAnyPublisher()
    }
}
