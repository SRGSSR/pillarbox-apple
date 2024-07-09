//
//  Copyright (c) SRG SSR. All rights reserved.
//
//  License information is available from the LICENSE file.
//

import AVFoundation

struct Queue {
    static let empty = Self(elements: [], itemState: .empty)

    let elements: [QueueElement]
    let itemState: ItemState

    var index: Int? {
        elements.firstIndex { $0.matches(itemState.item) }
    }

    var item: PlayerItem? {
        guard let index else { return nil }
        return elements[index].item
    }

    var error: Error? {
        itemState.error
    }

    private var playerItem: AVPlayerItem? {
        itemState.item
    }

    init(elements: [QueueElement], itemState: ItemState) {
        self.elements = elements
        self.itemState = !elements.isEmpty ? itemState : .empty
    }

    static func buffer(from previous: Self, to current: Self, length: Int) -> QueueBuffer? {
        if let previousItem = previous.playerItem, previous.error != nil, previous.index != nil {
            return .init(item: previousItem, length: 1)
        }
        else if let currentItem = current.playerItem, current.error != nil {
            return .init(item: currentItem, length: 1)
        }
        else if let currentItem = current.playerItem {
            return .init(item: currentItem, length: length)
        }
        else if previous.playerItem != nil, !current.elements.isEmpty {
            return nil
        }
        else {
            return .init(item: nil, length: length)
        }
    }

    func updated(with update: QueueUpdate) -> Self {
        switch update {
        case let .elements(elements):
            return .init(elements: elements, itemState: itemState)
        case let .itemState(itemState):
            return .init(elements: elements, itemState: itemState)
        }
    }
}
