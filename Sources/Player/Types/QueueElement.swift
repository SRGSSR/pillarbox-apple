//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct QueueElement {
    let item: PlayerItem
    let content: any PlayerItemContent

    init(item: PlayerItem, content: any PlayerItemContent) {
        assert(item.id == content.id)
        self.item = item
        self.content = content
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        item.matches(playerItem)
    }
}
