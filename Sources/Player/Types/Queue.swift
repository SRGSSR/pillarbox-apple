//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct QueueElement {
    let item: PlayerItem
    let asset: any Assetable
}

enum QueueUpdate {
    case elements([QueueElement])
    case itemTransition(ItemTransition)
}

struct Queue {
    static var initial: Self {
        .init(elements: [], itemTransition: .go(to: nil))
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
