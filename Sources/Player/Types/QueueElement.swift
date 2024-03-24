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

    func matches(_ element: QueueElement) -> Bool {
        content.matches(element.content)
    }

    func isIdentical(to element: QueueElement) -> Bool {
        content.isIdentical(to: element.content)
    }

    func playerItem(reload: Bool) -> AVPlayerItem {
        .init(url: URL(string: "")!)
//        if reload, resource.isFailing {
//            let item = Resource.loading.playerItem().withId(id)
//            configuration?(item)
//            update(item: item)
//            trigger.reload()
//            return item
//        }
//        else {
//            let item = resource.playerItem().withId(id)
//            configuration?(item)
//            update(item: item)
//            trigger.load()
//            return item
//        }
    }
}
