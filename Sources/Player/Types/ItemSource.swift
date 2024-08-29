//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct ItemSource {
    let content: AssetContent
    let item: AVPlayerItem?

    private init(content: AssetContent, item: AVPlayerItem?) {
        self.content = content
        self.item = item
    }

    static func new(content: AssetContent) -> Self {
        .init(content: content, item: nil)
    }

    static func reused(content: AssetContent, item: AVPlayerItem) -> Self {
        .init(content: content, item: item)
    }

    func playerItem(reload: Bool) -> AVPlayerItem {
        if let item {
            return item.updated(with: content)
        }
        else {
            return content.playerItem(reload: reload)
        }
    }
}
