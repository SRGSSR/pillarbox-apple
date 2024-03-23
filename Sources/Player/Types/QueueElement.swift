//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct QueueElement {
    let item: PlayerItem
    let content: ItemContent

    init(item: PlayerItem, content: ItemContent) {
        self.item = item
        self.content = content
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        content.matches(playerItem)
    }
}
