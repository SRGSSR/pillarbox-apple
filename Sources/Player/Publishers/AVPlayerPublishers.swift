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

    func itemTransitionPublisher() -> AnyPublisher<ItemTransition, Never> {
        itemUpdatePublisher()
            .withPrevious(.init(item: currentItem, error: currentItem?.error))
            .map { ItemTransition.transition(from: $0.previous, to: $0.current) }
            .removeDuplicates()
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
}

private extension AVPlayer {
    private func itemUpdatePublisher() -> AnyPublisher<ItemUpdate, Never> {
        currentItemPublisher()
            .map { item -> AnyPublisher<ItemUpdate, Never> in
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
                    return Just(.init(item: nil, error: nil)).eraseToAnyPublisher()
                }
            }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
