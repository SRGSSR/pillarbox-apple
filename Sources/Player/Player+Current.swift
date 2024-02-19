//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension Player {
    func queueItemsPublisher() -> AnyPublisher<[AVPlayerItem], Never> {
        Publishers.Merge(
            assetsPublisher()
                .map { ItemQueueUpdate.assets($0) },
            queuePlayer.itemTransitionPublisher()
                .map { ItemQueueUpdate.itemTransition($0) }
        )
        .scan(ItemQueue.initial) { queue, update in
            queue.updated(with: update)
        }
        .withPrevious(ItemQueue.initial)
        .compactMap { [configuration] previous, current in
            switch current.itemTransition {
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
