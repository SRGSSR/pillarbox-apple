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

        static func diff(_ current: ItemUpdate, _ previous: ItemUpdate?, length: Int) -> [PlayerItem] {
            guard let previous else { return current.queue(length: length) }
            return current.queue(length: length).filter { item in
                !previous.queue(length: length).contains(item)
            }
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
