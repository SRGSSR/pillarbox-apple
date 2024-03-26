//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct QueueElement {
    let item: PlayerItem
    let content: AssetContent

    init(item: PlayerItem, content: AssetContent) {
        assert(item.id == content.id)
        self.item = item
        self.content = content
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        item.matches(playerItem)
    }
}
