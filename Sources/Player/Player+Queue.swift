//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import PillarboxCore

extension Player {
    func elementsQueueUpdatePublisher() -> AnyPublisher<QueueUpdate, Never> {
        $storedItems
            .map { items in
                Publishers.AccumulateLatestMany(items.map { item in
                    item.$content
                        .map { QueueElement(item: item, asset: $0) }
                })
            }
            .switchToLatest()
            .map { .elements($0) }
            .eraseToAnyPublisher()
    }

    func itemStateQueueUpdatePublisher() -> AnyPublisher<QueueUpdate, Never> {
        queuePlayer.itemStatePublisher()
            .map { .itemState($0) }
            .eraseToAnyPublisher()
    }

    func queuePlayerItemsPublisher() -> AnyPublisher<[AVPlayerItem], Never> {
        queuePublisher
            .withPrevious(.empty)
            .compactMap { [configuration] previous, current in
                guard let buffer = Queue.buffer(from: previous, to: current, length: configuration.preloadedItems) else {
                    return nil
                }
                return AVPlayerItem.playerItems(
                    for: current.elements.map(\.asset),
                    replacing: previous.elements.map(\.asset),
                    currentItem: buffer.item,
                    length: buffer.length
                )
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
