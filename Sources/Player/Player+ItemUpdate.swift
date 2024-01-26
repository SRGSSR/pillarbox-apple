//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import DequeModule

extension Player {
    struct ItemUpdate {
        static var empty: Self {
            .init(items: [], currentItem: nil)
        }

        let items: Deque<PlayerItem>
        let currentItem: AVPlayerItem?

        static func updatedItems(current: Self, previous: Self?, length: Int) -> [PlayerItem] {
            let currentQueue = current.queue(length: length)
            guard let previous else { return currentQueue }
            let previousQueue = previous.queue(length: length)
            return currentQueue.filter { !previousQueue.contains($0) }
        }

        func currentIndex() -> Int? {
            items.firstIndex { $0.matches(currentItem) }
        }

        func queue(length: Int) -> [PlayerItem] {
            guard let index = currentIndex() else { return [] }
            return Array(items.suffix(from: index).prefix(length))
        }
    }
}
