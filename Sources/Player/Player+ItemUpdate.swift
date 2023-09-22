//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import Combine
import DequeModule

extension Player {
    struct ItemUpdate {
        let items: Deque<PlayerItem>
        let currentItem: AVPlayerItem?

        func currentIndex() -> Int? {
            items.firstIndex { $0.matches(currentItem) }
        }

        func streamTypePublisher() -> AnyPublisher<StreamType, Never> {
            guard let currentItem else { return Just(.unknown).eraseToAnyPublisher() }
            return currentItem.streamTypePublisher().eraseToAnyPublisher()
        }
    }

    func itemUpdatePublisher() -> AnyPublisher<ItemUpdate, Never> {
        Publishers.CombineLatest($storedItems, queuePlayer.publisher(for: \.currentItem))
            .map { ItemUpdate(items: $0, currentItem: $1) }
            .eraseToAnyPublisher()
    }
}
