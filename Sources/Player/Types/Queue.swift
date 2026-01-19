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

    private var index: Int? {
        elements.firstIndex { $0.matches(itemState.item) }
    }

    var item: PlayerItem? {
        guard let index else { return nil }
        return elements[index].item
    }

    private var content: AssetContent? {
        guard let index else { return nil }
        return elements[index].content
    }

    var items: QueueItems? {
        guard let item, let playerItem else { return nil }
        return .init(item: item, playerItem: playerItem)
    }

    var error: Error? {
        content?.resource.error ?? itemState.error
    }

    var isActive: Bool {
        playerItem != nil && error == nil
    }

    private var playerItem: AVPlayerItem? {
        itemState.item
    }

    init(elements: [QueueElement], itemState: ItemState) {
        self.elements = elements
        self.itemState = !elements.isEmpty ? itemState : .empty
    }

    static func buffer(from previous: Self, to current: Self, length: Int) -> QueueBuffer? {
        if let previousItem = previous.playerItem, previousItem.error != nil, previous.index != nil {
            return .init(item: previousItem, length: 1)
        }
        else if let currentItem = current.playerItem, currentItem.error != nil {
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
