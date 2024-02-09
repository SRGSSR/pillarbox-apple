//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension AVPlayer {
    func smoothItemPublisher() -> AnyPublisher<AVPlayerItem?, Never> {
        itemTransitionPublisher()
            .map { transition in
                switch transition {
                case let .advance(to: item):
                    return item
                case let .stop(on: item):
                    return item
                case let .finish(with: item):
                    return item
                }
            }
            .eraseToAnyPublisher()
    }

    func itemTransitionPublisher() -> AnyPublisher<ItemTransition, Never> {
        publisher(for: \.currentItem)
            .withPrevious(nil)
            .map { item in
                if let currentItem = item.current {
                    if let previousItem = item.previous, previousItem.error != nil {
                        return .stop(on: previousItem)
                    }
                    else if currentItem.error == nil {
                        return .advance(to: currentItem)
                    }
                    else {
                        return .stop(on: currentItem)
                    }
                }
                else if let previousItem = item.previous {
                    if previousItem.error == nil {
                        return .finish(with: previousItem)
                    }
                    else {
                        return .stop(on: previousItem)
                    }
                }
                else {
                    return .advance(to: nil)
                }
            }
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
