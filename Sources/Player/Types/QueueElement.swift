//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct QueueElement {
    let item: PlayerItem
    let asset: any Assetable

    init(item: PlayerItem, asset: any Assetable) {
        assert(item.id == asset.id)
        self.item = item
        self.asset = asset
    }

    func matches(_ playerItem: AVPlayerItem?) -> Bool {
        item.matches(playerItem)
    }
}
