//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension AVPlayer {
    func currentItemPublisher() -> AnyPublisher<AVPlayerItem?, Never> {
        publisher(for: \.currentItem)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func itemStatePublisher() -> AnyPublisher<ItemState, Never> {
        currentItemPublisher()
            .map { item -> AnyPublisher<ItemState, Never> in
                if let item {
                    if let error = item.error {
                        return Just(.init(item: item, error: error)).eraseToAnyPublisher()
                    }
                    else {
                        return item.errorPublisher()
                            .map { .init(item: item, error: $0) }
                            .prepend(.init(item: item, error: nil))
                            .eraseToAnyPublisher()
                    }
                }
                else {
                    return Just(.empty).eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .withPrevious(.empty)
            .map { state in
                // `AVQueuePlayer` sometimes consumes failed items, transitioning to `nil`, sometimes not. We can
                // make this behavior consistent by never consuming failed states.
                if state.current.item == nil && state.previous.error != nil {
                    return state.previous
                }
                else {
                    return state.current
                }
            }
            .eraseToAnyPublisher()
    }

    func playerItemPropertiesPublisher() -> AnyPublisher<PlayerItemProperties, Never> {
        currentItemPublisher()
            .map { item in
                guard let item else { return Just(PlayerItemProperties.empty).eraseToAnyPublisher() }
                return item.propertiesPublisher()
            }
            .switchToLatest()
            .prepend(.empty)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func playbackPropertiesPublisher() -> AnyPublisher<PlaybackProperties, Never> {
        Publishers.CombineLatest3(
            publisher(for: \.rate),
            publisher(for: \.isExternalPlaybackActive),
            publisher(for: \.isMuted)
        )
        .map { .init(rate: $0, isExternalPlaybackActive: $1, isMuted: $2) }
        .removeDuplicates()
        .eraseToAnyPublisher()
    }

    func initialPlaybackLikelyToKeepUpDateIntervalPublisher() -> AnyPublisher<MetricLogUpdate, Never> {
            currentItemPublisher()
                .compactMap { $0 }
                .filter { !$0.isLoading }
                .map { item in
                    item.initialPlaybackLikelyToKeepUpPublisher()
                        .measureDateInterval()
                        .map { .init(log: item.metricLog, event: .init(id: item.id, kind: .resourceLoading($0), time: item.currentTime())) }
                }
                .switchToLatest()
                .eraseToAnyPublisher()
        }
}
