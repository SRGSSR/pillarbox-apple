//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension AVPlayer {
    /// Publishes a stream of `AVPlayerItem` which preserves failed items.
    func smoothCurrentItemPublisher() -> AnyPublisher<AVPlayerItem?, Never> {
        itemTransitionPublisher()
            .map { transition in
                switch transition {
                case let .advance(to: item):
                    return item
                case let .stop(on: item):
                    return item
                case .finish:
                    return nil
                }
            }
            .eraseToAnyPublisher()
    }

    func itemTransitionPublisher() -> AnyPublisher<ItemTransition, Never> {
        publisher(for: \.currentItem)
            .removeDuplicates()
            .withPrevious(nil)
            .map { ItemTransition.transition(from: $0.previous, to: $0.current) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func playerItemPropertiesPublisher() -> AnyPublisher<PlayerItemProperties, Never> {
        publisher(for: \.currentItem)
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

    func errorPublisher() -> AnyPublisher<Error?, Never> {
        publisher(for: \.currentItem)
            .compactMap { $0?.errorPublisher() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}
