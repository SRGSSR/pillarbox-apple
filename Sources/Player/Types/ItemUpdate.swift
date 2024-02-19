//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation
import DequeModule

struct ItemUpdate {
    static var empty: Self {
        .init(items: [], currentItem: nil)
    }

    let items: Deque<PlayerItem>
    let currentItem: AVPlayerItem?

    var currentIndex: Int? {
        items.firstIndex { $0.matches(currentItem) }
    }

    var currentPlayerItem: PlayerItem? {
        items.first { $0.matches(currentItem) }
    }
}
