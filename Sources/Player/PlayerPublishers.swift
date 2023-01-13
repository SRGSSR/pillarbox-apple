//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
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
                return Publishers.CombineLatest(
                    item.publisher(for: \.status),
                    item.publisher(for: \.duration)
                )
                .map { status, duration in
                    status == .readyToPlay ? duration : .invalid
                }
                .eraseToAnyPublisher()
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
            NotificationCenter.default.weakPublisher(for: .willSeek, object: self)
                .map { _ in true },
            NotificationCenter.default.weakPublisher(for: .didSeek, object: self)
                .map { _ in false }
        )
        .prepend(false)
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
            }
            .switchToLatest()
            .map { isPlaybackLikelyToKeepUp, itemState in
                switch itemState {
                case .failed:
                    return false
                default:
                    return !isPlaybackLikelyToKeepUp
                }
            }
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
}
