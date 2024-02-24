//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import Combine
import Foundation
import PillarboxCore

extension Player {
    func elementsQueueUpdatePublisher() -> AnyPublisher<QueueUpdate, Never> {
        $storedItems
            .map { items in
                Publishers.AccumulateLatestMany(items.map { item in
                    item.$asset
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
}
