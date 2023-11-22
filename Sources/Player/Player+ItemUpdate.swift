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

        func currentIndex() -> Int? {
            items.firstIndex { $0.matches(currentItem) }
        }
    }
}
