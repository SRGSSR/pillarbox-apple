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
                        .map { QueueElement(item: item, content: $0) }
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
            .compactMap { [weak self] previous, current in
                guard let self, let buffer = Queue.buffer(from: previous, to: current, length: self.configuration.preloadedItems) else {
                    return nil
                }
                return AVPlayerItem.playerItems(
                    for: current.elements.map(\.content),
                    replacing: previous.elements.map(\.content),
                    currentItem: buffer.item,
                    repeatMode: repeatMode,
                    length: buffer.length,
                    configuration: self.configuration,
                    resumeState: resumeState,
                    limits: self.limits
                )
            }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
