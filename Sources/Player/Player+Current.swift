//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension Player {
    func currentPublisher() -> AnyPublisher<Current?, Never> {
        itemUpdatePublisher
            .map { update in
                guard let currentIndex = update.currentIndex() else { return nil }
                return .init(item: update.items[currentIndex], index: currentIndex)
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    func queueItemsPublisher() -> AnyPublisher<[AVPlayerItem], Never> {
        Publishers.CombineLatest(
            assetsPublisher(),
            queuePlayer.itemTransitionPublisher()
        )
        .map { QueueUpdate(assets: $0, transition: $1) }
        .withPrevious(.initial)
        .compactMap { [configuration] previous, current in
            switch current.transition {
            case let .advance(item):
                return AVPlayerItem.playerItems(
                    for: current.assets,
                    replacing: previous.assets,
                    currentItem: item,
                    length: configuration.preloadedItems
                )
            case let .stop(item):
                return [item]
            case .finish:
                return nil
            }
        }
        .eraseToAnyPublisher()
    }
}
