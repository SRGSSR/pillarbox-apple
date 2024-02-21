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

enum QueueUpdate {
    case elements([QueueElement])
    case itemTransition(ItemTransition)
}

struct Queue {
    static var initial: Self {
        .init(elements: [], itemTransition: .go(to: nil))
    }

    var currentIndex: Int? {
        elements.firstIndex { $0.matches(itemTransition.playerItem) }
    }

    var currentItem: PlayerItem? {
        guard let currentIndex else { return nil }
        return elements[currentIndex].item
    }

    var error: Error? {
        guard let item = itemTransition.playerItem else { return nil }
        return item.error
    }

    let elements: [QueueElement]
    let itemTransition: ItemTransition

    init(elements: [QueueElement], itemTransition: ItemTransition) {
        self.elements = elements
        self.itemTransition = !elements.isEmpty ? itemTransition : .go(to: nil)
    }

    func updated(with update: QueueUpdate) -> Self {
        switch update {
        case let .elements(elements):
            return .init(elements: elements, itemTransition: itemTransition)
        case let .itemTransition(itemTransition):
            return .init(elements: elements, itemTransition: itemTransition)
        }
    }
}
